"""ContractForge pipeline entry point. Run every part of the pipeline from here.

Stages run in order up to --until:
    parse   requirements XML → requirements JSON (deterministic, no model)
    spec    L0: one Lean spec (pre/post predicates) per requirements entry
    check   L0.5: rule-based checks that each spec is not empty or wrong (validate.py);
            writes a report and review.json with a decision per entry
    (L1 architect and L2 coding stages are not wired in yet)

Run from harness/:
    python main.py                                  # every XML in Requirements/, model qwen
    python main.py "../Requirements/0000 - gamma j.xml" --model deepseek
    python main.py --until parse                    # only the parser
    python main.py --limit 5                        # first 5 entries only
    python main.py --only 5.1/R4 DD-user-id         # rerun specific entries (others are kept)
    python main.py --kinds data_constraint          # requirement | data_constraint | use_case
    python main.py --resume                         # skip entries that already passed
    python main.py --skip-lean                      # collect specs without Lean (unchecked)

With --model qwen, the local llama.cpp server is started automatically if it is not
already running (needs a GPU node: srun -p u22 --gres=gpu:1 --pty bash), and stopped
again at the end.

Outputs, per input document <stem>:
    Requirements/parsed/<stem>.json                 parser output
    runs/<stem>/<model>/specs.json                  text predicate + Lean predicate per entry
    runs/<stem>/<model>/lean/<id>.lean              each Lean spec as a file
    runs/<stem>/<model>/l05_report.md               L0.5 verdict per entry (pass / flag / fail)
    runs/<stem>/<model>/review.json                 decision per entry (accept / review / redo / exclude)
specs.json is rewritten after every entry, so a crash or Ctrl-C loses nothing.
"""
import argparse
import atexit
import json
import os
import re
import shutil
import subprocess
import sys
import time
import urllib.request
from pathlib import Path

from config import BASE_URLS, FRAMEWORK_PATH, ROOT
from req_parser import parse_file, to_json

STAGES = ["parse", "spec", "check"]
REQ_DIR = ROOT / "Requirements"
PARSED_DIR = REQ_DIR / "parsed"
RUNS_DIR = ROOT / "runs"
QWEN_SCRIPT = ROOT / "scripts" / "start_qwen_server.sh"
QWEN_STARTUP_SECS = 240


def _fail(msg: str) -> None:
    sys.exit(f"error: {msg}")


# ---------------------------------------------------------------------------
# Preflight: Lean and the model must be reachable before any model call.
# ---------------------------------------------------------------------------

def _qwen_up() -> bool:
    try:
        urllib.request.urlopen(BASE_URLS["qwen"].rstrip("/") + "/models", timeout=5)
        return True
    except Exception:
        return False


def ensure_qwen_server() -> None:
    """Start the local Qwen server if it is not running; stop it when we exit."""
    if _qwen_up():
        return
    log = RUNS_DIR / "qwen_server.log"
    log.parent.mkdir(parents=True, exist_ok=True)
    print(f"starting Qwen server ({BASE_URLS['qwen']}, log: {log.relative_to(ROOT)})")
    with open(log, "w") as fh:
        proc = subprocess.Popen(["bash", str(QWEN_SCRIPT)], stdout=fh, stderr=subprocess.STDOUT)
    atexit.register(proc.terminate)
    deadline = time.time() + QWEN_STARTUP_SECS
    while time.time() < deadline:
        if proc.poll() is not None:
            _fail(f"Qwen server exited (code {proc.returncode}); see {log}. "
                  "It needs a GPU node: srun -p u22 --gres=gpu:1 --pty bash")
        if _qwen_up():
            print("Qwen server ready")
            return
        time.sleep(2)
    _fail(f"Qwen server not ready after {QWEN_STARTUP_SECS}s; see {log}")


def preflight(model: str, skip_lean: bool) -> None:
    if not skip_lean:
        if shutil.which("lake") is None:
            _fail("Lean (`lake`) is not on PATH. Install elan / Lean "
                  f"{(FRAMEWORK_PATH / 'lean-toolchain').read_text().strip()}, "
                  "or run with --skip-lean to collect unchecked specs.")
        if not (FRAMEWORK_PATH / ".lake").exists():
            from lean_runner import build_framework
            print("building Lean framework (first run)...")
            build_framework()
    if model == "qwen":
        ensure_qwen_server()
    else:
        from llm import _api_key
        try:
            _api_key(model)
        except (RuntimeError, KeyError) as e:
            _fail(str(e))


# ---------------------------------------------------------------------------
# Stage: parse
# ---------------------------------------------------------------------------

def stage_parse(path: Path) -> dict:
    """XML → parse and save the JSON; JSON → load as is."""
    if path.suffix.lower() == ".json":
        return json.loads(path.read_text(encoding="utf-8"))
    doc = parse_file(path)
    PARSED_DIR.mkdir(parents=True, exist_ok=True)
    out = PARSED_DIR / f"{path.stem}.json"
    out.write_text(to_json(doc), encoding="utf-8")
    print(f"[parse] {path.name}: {doc['stats']} -> {out.relative_to(ROOT)}")
    return doc


# ---------------------------------------------------------------------------
# Stage: spec (L0)
# ---------------------------------------------------------------------------

def _write_json(path: Path, data) -> None:
    tmp = path.with_suffix(".tmp")
    tmp.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    os.replace(tmp, path)


def _safe(name: str) -> str:
    return re.sub(r"[^A-Za-z0-9_.-]+", "_", name)


def _generate_spec(p: dict, model: str, skip_lean: bool) -> dict:
    from agents.spec_agent import SYSTEM_PROMPT_SPEC, run_spec
    from validate import hard_checks
    prompt = p["prompt"]
    if not skip_lean:
        r = run_spec(prompt, model, validate=hard_checks(p["entry"]))
        # `success` also needs the L0.5 checks; record plain compilation separately.
        if r["success"]:
            r["compiles"] = True
        else:
            from lean_runner import check_lean
            r["compiles"] = bool(r["code"]) and check_lean(r["code"])["success"]
        return r
    from llm import call_llm, extract_lean
    return {"success": None, "code": extract_lean(call_llm(prompt, system=SYSTEM_PROMPT_SPEC, model=model)),
            "attempts": 1, "compiles": None}


def _lean_file(p: dict, r: dict) -> str:
    """A saved spec that compiles on its own: the same prelude `check_lean` adds, then the code."""
    from lean_runner import HEADER
    text = " ".join(p["text"].split())
    return (f"{HEADER}-- {p['id']}: {text}\n"
            f"-- compiles: {r.get('compiles')} · checked: {r['success']}\n\n{r['code']}\n")


def stage_spec(doc: dict, stem: str, args) -> dict:
    from agents.spec_agent import spec_prompts

    all_prompts = spec_prompts(doc)
    items = all_prompts
    if args.kinds:
        items = [p for p in items if p["kind"] in args.kinds]
    if args.only:
        items = [p for p in items if p["id"] in args.only]
    if args.limit:
        items = items[:args.limit]

    out_dir = RUNS_DIR / stem / args.model
    lean_dir = out_dir / "lean"
    lean_dir.mkdir(parents=True, exist_ok=True)
    specs_path = out_dir / "specs.json"

    # Keep earlier results when resuming or running a subset, so `--only X` reruns X
    # without dropping every other entry from specs.json.
    results = {}
    subset = bool(args.only or args.kinds or args.limit)
    if (args.resume or subset) and specs_path.exists():
        results = {r["id"]: r for r in json.loads(specs_path.read_text(encoding="utf-8"))["results"]}

    def save() -> dict:
        ordered = [results[p["id"]] for p in all_prompts if p["id"] in results]
        summary = {"total": len(ordered),
                   "compiles": sum(r.get("compiles") is True for r in ordered),
                   "checked": sum(r["checked"] is True for r in ordered),
                   "failed": sum(r["checked"] is False for r in ordered),
                   "unchecked": sum(r["checked"] is None for r in ordered)}
        _write_json(specs_path, {"source": doc["source"], "model": args.model,
                                 "lean_checked": not args.skip_lean,
                                 "summary": summary, "results": ordered})
        return summary

    for i, p in enumerate(items, 1):
        prev = results.get(p["id"])
        if args.resume and prev and prev["checked"] is not False:
            print(f"[spec {i}/{len(items)}] {p['id']}: skipped (done)")
            continue
        t0 = time.time()
        try:
            r = _generate_spec(p, args.model, args.skip_lean)
        except KeyboardInterrupt:
            save()
            raise
        except Exception as e:  # one bad entry must not stop the run
            r = {"success": False, "code": "", "attempts": 0, "error": f"{type(e).__name__}: {e}"}
        secs = round(time.time() - t0, 1)
        results[p["id"]] = {
            "id": p["id"], "kind": p["kind"], "verification": p["verification"],
            "requirement_text": p["text"], "text_predicate": p["prompt"],
            "lean_predicate": r["code"], "compiles": r.get("compiles"), "checked": r["success"],
            "attempts": r.get("attempts"), "seconds": secs,
            **({"error": r["error"]} if r.get("error") else {}),
            **({"log": r["log"]} if r.get("log") else {}),
        }
        (lean_dir / f"{_safe(p['id'])}.lean").write_text(_lean_file(p, r), encoding="utf-8")
        save()
        status = {True: "OK", False: "FAILED", None: "unchecked"}[r["success"]]
        print(f"[spec {i}/{len(items)}] {p['id']}: {status} ({r.get('attempts')} attempts, {secs}s)")

    summary = save()
    print(f"[spec] {stem}: {summary} -> {specs_path.relative_to(ROOT)}")
    return summary


# ---------------------------------------------------------------------------
# Stage: check (L0.5)
# ---------------------------------------------------------------------------

def stage_check(doc: dict, stem: str, args) -> dict:
    """Review every spec, write the report and review.json, then apply --on-l0-fail."""
    from validate import review_run, write_report

    out_dir = RUNS_DIR / stem / args.model
    specs_path = out_dir / "specs.json"
    if not specs_path.exists():
        _fail(f"no specs to check: {specs_path.relative_to(ROOT)} (run the spec stage first)")
    entries = {e["id"]: e for e in doc["requirements"] + doc["data_dictionary"] + doc["use_cases"]}
    specs = json.loads(specs_path.read_text(encoding="utf-8"))
    counts = review_run(specs, entries)
    _write_json(specs_path, specs)
    report = write_report(specs, out_dir)
    print(f"[check] {stem}: {counts} -> {report.relative_to(ROOT)}")

    failed = [r["id"] for r in specs["results"] if r["l05"]["status"] == "fail"]
    if not failed:
        return counts
    if args.on_l0_fail == "redo" and not getattr(args, "_redone", False):
        print(f"[check] redoing L0 for {len(failed)} failed entries")
        redo = argparse.Namespace(**{**vars(args), "only": failed, "resume": True, "kinds": None,
                                     "limit": None, "_redone": True})
        for r in specs["results"]:  # make --resume retry them
            if r["id"] in failed:
                r["checked"] = False
        _write_json(specs_path, specs)
        stage_spec(doc, stem, redo)
        return stage_check(doc, stem, redo)
    if args.on_l0_fail == "exclude":
        review_path = out_dir / "review.json"
        decisions = json.loads(review_path.read_text(encoding="utf-8"))
        for i in failed:
            decisions[i]["decision"] = "exclude"
        _write_json(review_path, decisions)
        print(f"[check] excluded {len(failed)} failed entries in {review_path.relative_to(ROOT)}")
    else:
        print(f"[check] {len(failed)} entries failed L0.5; stopping before L1. Edit "
              f"{(out_dir / 'review.json').relative_to(ROOT)} or rerun with --on-l0-fail redo|exclude")
    return counts


# ---------------------------------------------------------------------------

def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description="ContractForge pipeline")
    ap.add_argument("inputs", nargs="*", help="requirements .xml or parsed .json (default: Requirements/*.xml)")
    ap.add_argument("--until", choices=STAGES, default=STAGES[-1], help="last stage to run (default: %(default)s)")
    ap.add_argument("--model", default=os.getenv("CF_MODEL", "qwen"),
                    help="qwen | deepseek | groq | gemma (default: $CF_MODEL or qwen)")
    ap.add_argument("--limit", type=int, help="only the first N entries")
    ap.add_argument("--only", nargs="+", metavar="ID", help="only these entry ids")
    ap.add_argument("--kinds", nargs="+", choices=["requirement", "data_constraint", "use_case"])
    ap.add_argument("--resume", action="store_true", help="skip entries already done in a previous run")
    ap.add_argument("--skip-lean", action="store_true", help="do not type-check (specs marked unchecked)")
    ap.add_argument("--on-l0-fail", choices=["stop", "redo", "exclude"], default="stop",
                    help="entries failing L0.5: stop before L1 (default), redo them once, or exclude them")
    args = ap.parse_args(argv)

    paths = [Path(p).resolve() for p in args.inputs] or sorted(REQ_DIR.glob("*.xml"))
    if not paths:
        _fail(f"no requirements XML found in {REQ_DIR}")
    run_spec_stage = STAGES.index(args.until) >= STAGES.index("spec")
    if run_spec_stage:
        preflight(args.model, args.skip_lean)

    for path in paths:
        doc = stage_parse(path)
        if run_spec_stage:
            stage_spec(doc, path.stem, args)
        if STAGES.index(args.until) >= STAGES.index("check") and not args.skip_lean:
            stage_check(doc, path.stem, args)
    return 0


if __name__ == "__main__":
    sys.exit(main())
