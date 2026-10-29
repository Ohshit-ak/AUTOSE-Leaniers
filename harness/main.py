"""ContractForge pipeline entry point. Run every part of the pipeline from here.

Stages run in order up to --until:
    parse   requirements XML → requirements JSON (deterministic, no model)
    spec    L0: one Lean spec (pre/post predicates) per requirements entry
    (L1 architect and L2 coding stages are not wired in yet)

Run from harness/:
    python main.py                                  # every XML in Requirements/, model qwen
    python main.py "../Requirements/0000 - gamma j.xml" --model deepseek
    python main.py --until parse                    # only the parser
    python main.py --limit 5                        # first 5 entries only
    python main.py --only 5.1/R4 DD-user-id         # specific entries
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

STAGES = ["parse", "spec"]
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


def _generate_spec(prompt: str, model: str, skip_lean: bool) -> dict:
    from agents.spec_agent import SYSTEM_PROMPT_SPEC, run_spec
    if not skip_lean:
        return run_spec(prompt, model)
    from llm import call_llm, extract_lean
    return {"success": None, "code": extract_lean(call_llm(prompt, system=SYSTEM_PROMPT_SPEC, model=model)),
            "attempts": 1}


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

    results = {}
    if args.resume and specs_path.exists():
        results = {r["id"]: r for r in json.loads(specs_path.read_text(encoding="utf-8"))["results"]}

    def save() -> dict:
        ordered = [results[p["id"]] for p in all_prompts if p["id"] in results]
        summary = {"total": len(ordered),
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
            r = _generate_spec(p["prompt"], args.model, args.skip_lean)
        except KeyboardInterrupt:
            save()
            raise
        except Exception as e:  # one bad entry must not stop the run
            r = {"success": False, "code": "", "attempts": 0, "error": f"{type(e).__name__}: {e}"}
        secs = round(time.time() - t0, 1)
        results[p["id"]] = {
            "id": p["id"], "kind": p["kind"], "verification": p["verification"],
            "requirement_text": p["text"], "text_predicate": p["prompt"],
            "lean_predicate": r["code"], "checked": r["success"],
            "attempts": r.get("attempts"), "seconds": secs,
            **({"error": r["error"]} if r.get("error") else {}),
        }
        (lean_dir / f"{_safe(p['id'])}.lean").write_text(
            f"-- {p['id']}: {p['text']}\n-- checked: {r['success']}\n\n{r['code']}\n", encoding="utf-8")
        save()
        status = {True: "OK", False: "FAILED", None: "unchecked"}[r["success"]]
        print(f"[spec {i}/{len(items)}] {p['id']}: {status} ({r.get('attempts')} attempts, {secs}s)")

    summary = save()
    print(f"[spec] {stem}: {summary} -> {specs_path.relative_to(ROOT)}")
    return summary


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
    return 0


if __name__ == "__main__":
    sys.exit(main())
