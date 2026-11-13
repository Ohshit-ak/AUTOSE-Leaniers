"""ContractForge pipeline entry point. Run every part of the pipeline from here.

Stages run in order up to --until:
    parse   requirements XML → requirements JSON (deterministic, no model)
    spec    L0: one Lean spec (pre/post predicates) per requirements entry
    check   L0.5: rule-based checks that each spec is not empty or wrong (validate.py);
            writes a report and review.json with a decision per entry
    graph   L1: deterministic requirements graph from the parsed SRS + a frozen L0 run +
            benchmark/<doc>/Domain.lean (req_graph.py, no model) → runs/<stem>/graph/
    arch    L1: per component group, component contracts + trace/PO1/PO2 proofs
            (agents/architect_agent.py) → runs/<stem>/<model>-L1-v1/rep<k>/arch/<group>/
    code    L2: per component group, component implementations + automated PO3 proofs +
            end-to-end sound theorem → runs/<stem>/<model>-L2-v1/rep<k>/code/<group>/
    chain   L1 + L2 per accepted L0 spec (the other L1/L2 path; not after `code`, an
            alternative to graph → arch → code): each spec is split into two chained contracts
            Input → Mid → Output, or kept whole if it is a single step; each contract is
            implemented; the harness states and proves PO1/PO2/PO3 and the end-to-end theorem
            (chain_pipeline.py) → runs/<stem>/<model>-chain-v4/rep<k>/
--until graph / --until arch / --until code / --until chain do NOT rerun L0: they read the frozen
L0 run (--l0-run, default runs/<stem>/qwen-v10.1/rep1) and frozen L1 run (--arch-run).

Run from harness/:
    python main.py                                  # every XML in Requirements/, model qwen
    python main.py "../Requirements/0000 - gamma j.xml" --model deepseek
    python main.py --until parse                    # only the parser
    python main.py --limit 5                        # first 5 entries only
    python main.py --only 5.1/R4 DD-user-id         # rerun specific entries (others are kept)
    python main.py --kinds data_constraint          # requirement | data_constraint | use_case
    python main.py --resume                         # skip entries that already passed
    python main.py --skip-lean                      # collect specs without Lean (unchecked)
    python main.py --repeat 3                       # 3 repetitions, seeds CF_SEED, +1, +2
    python main.py "../Requirements/0000 - gamma j.xml" --until graph       # graph only, no model
    python main.py "../Requirements/0000 - gamma j.xml" --until arch --repeat 3            # L1
    python main.py "../Requirements/0000 - gamma j.xml" --until arch --no-graph --repeat 3 # baseline
    python main.py … --until arch --component AccountSys    # one component group only
    python main.py "../Requirements/0000 - gamma j.xml" --until chain --repeat 3           # chain L1 + L2
    python main.py … --until chain --only 5.3/R4 --fallback-single
    python ../evaluation/summarize_e2e.py "../runs/0000 - gamma j/qwen-chain-v4"           # results + spread

With --model qwen, the local llama.cpp server is started automatically if it is not
already running (needs a GPU node: srun -p u22 --gres=gpu:1 --pty bash), and stopped
again at the end.

Outputs, per input document <stem>:
    Requirements/parsed/<stem>.json                 parser output
    runs/<stem>/<model>/specs.json                  text predicate + Lean predicate per entry
    runs/<stem>/<model>/lean/<id>.lean              each Lean spec as a file
    runs/<stem>/<model>/l05_report.md               L0.5 verdict per entry (pass / flag / fail)
    runs/<stem>/<model>/review.json                 decision per entry (accept / review / redo / exclude)
With --repeat N the run folder is runs/<stem>/<model>-<version>/rep<k>/ (k = 1 … N), each
repetition with its own seed. Compare runs with evaluation/compare_runs.py.
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

from config import BASE_URLS, FRAMEWORK_PATH, HARNESS_VERSION, MODELS, ROOT, SEED
from req_parser import parse_file, to_json

STAGES = ["parse", "spec", "check", "graph", "arch", "code", "chain"]
DEFAULT_UNTIL = "code"   # `chain` is the alternative L1/L2 path, chosen with --until chain
L1_STAGES = {"graph", "arch"}
L1_VERSION = "L1-v1"
L2_STAGES = {"code"}
L2_VERSION = "L2-v1"
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

def run_dir(stem: str, args) -> Path:
    """Output folder of this run (and repetition)."""
    name = args.run_name or (f"{args.model}-{HARNESS_VERSION}" if args.repeat else args.model)
    d = RUNS_DIR / stem / name
    return d / f"rep{args.rep}" if args.repeat else d


def run_meta(args) -> dict:
    """What produced a run: enough to tell whether two runs are comparable."""
    from agents.spec_agent import prompt_hash
    from config import RESTART_TEMPERATURE, TEMPERATURE
    from llm import current_seed
    try:
        commit = subprocess.run(["git", "rev-parse", "--short", "HEAD"], cwd=ROOT, text=True,
                                capture_output=True).stdout.strip() or None
        dirty = bool(subprocess.run(["git", "status", "--porcelain", "harness", "framework"],
                                    cwd=ROOT, text=True, capture_output=True).stdout.strip())
    except OSError:
        commit, dirty = None, None
    return {"harness_version": HARNESS_VERSION, "model": args.model, "model_id": MODELS.get(args.model),
            "temperature": TEMPERATURE, "restart_temperature": RESTART_TEMPERATURE,
            "seed": current_seed(args.model), "repetition": args.rep if args.repeat else None,
            "prompt_hash": prompt_hash(), "git_commit": commit, "git_dirty": dirty}


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
        r = run_spec(prompt, model, validate=hard_checks(p["entry"]), entry=p["entry"])
        # `success` also needs the L0.5 checks; record plain compilation separately.
        if r["success"]:
            r["compiles"] = True
        else:
            from lean_runner import check_lean
            r["compiles"] = bool(r["code"]) and check_lean(r["code"])["success"]
        return r
    from llm import call_llm, extract_lean
    return {"success": None, "code": extract_lean(call_llm(prompt, system=SYSTEM_PROMPT_SPEC, model=model)),
            "attempts": 1, "compiles": None, "rejects_bad_example": None, "bad_example": None}


def _lean_file(p: dict, r: dict) -> str:
    """A saved spec that compiles on its own: the same prelude `check_lean` adds, then the code."""
    from lean_runner import HEADER
    text = " ".join(p["text"].split())
    return (f"{HEADER}-- {p['id']}: {text}\n"
            f"-- compiles: {r.get('compiles')} · rejects_bad_example: {r.get('rejects_bad_example')}"
            f" · checked: {r['success']}\n\n{r['code']}\n")


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

    out_dir = run_dir(stem, args)
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
                   "rejects_bad_example": sum(r.get("rejects_bad_example") is True for r in ordered),
                   "checked": sum(r["checked"] is True for r in ordered),
                   "failed": sum(r["checked"] is False for r in ordered),
                   "unchecked": sum(r["checked"] is None for r in ordered)}
        _write_json(specs_path, {"source": doc["source"], "model": args.model,
                                 "meta": run_meta(args), "lean_checked": not args.skip_lean,
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
            "lean_predicate": r["code"], "compiles": r.get("compiles"),
            "rejects_bad_example": r.get("rejects_bad_example"), "bad_example": r.get("bad_example"),
            "negative_verdict": r.get("negative_verdict", "unknown"),
            "negative_examples": r.get("negative_examples", []),
            "checked": r["success"],
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

    out_dir = run_dir(stem, args)
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
# Stages: graph and arch (L1). They read a frozen L0 run and never change it.
# ---------------------------------------------------------------------------

def l0_run_dir(stem: str, args) -> Path:
    if args.l0_run:
        return Path(args.l0_run).resolve()
    from req_graph import DEFAULT_L0_RUN
    return RUNS_DIR / stem / DEFAULT_L0_RUN


def stage_graph(stem: str, args) -> dict:
    import req_graph
    g = req_graph.run(stem, l0_run_dir(stem, args), vocab=args.vocab)
    m = g["metrics"]
    print(f"[graph] {stem}: {m['pct_fields_mapped']}% fields mapped, {m['groups']} groups, "
          f"{m['components']} components, {m['cycles']} cycles ({m['merged_component_sets']} merged) "
          f"-> {(RUNS_DIR / stem / 'graph' / 'graph.json').relative_to(ROOT)}")
    if not g["inputs"]["domain"]:
        print(f"[graph] warning: no {req_graph.benchmark_dir(stem).relative_to(ROOT)}/Domain.lean; "
              "entities come from the SRS only")
    return g


def arch_run_dir(stem: str, args) -> Path:
    name = args.run_name or f"{args.model}-{L1_VERSION}" + ("-nograph" if args.no_graph else "")
    d = RUNS_DIR / stem / name
    return d / f"rep{args.rep}" if args.repeat else d


def code_run_dir(stem: str, args) -> Path:
    name = args.run_name or f"{args.model}-{L2_VERSION}"
    d = RUNS_DIR / stem / name
    return d / f"rep{args.rep}" if args.repeat else d


def arch_meta(stem: str, args, graph_path: Path) -> dict:
    from agents.architect_agent import prompt_hash
    meta = run_meta(args)
    meta.update(harness_version=L1_VERSION, prompt_hash=prompt_hash(),
                l0_prompt_hash=meta.get("prompt_hash"), graph_sha=_sha(graph_path),
                l0_run=str(l0_run_dir(stem, args).relative_to(ROOT)),
                graph_mode="no-graph" if args.no_graph else "graph", arch_mode=args.arch_mode)
    return meta


def _sha(path: Path):
    import hashlib
    return hashlib.sha256(path.read_bytes()).hexdigest()[:12] if path.exists() else None


def stage_arch(stem: str, args) -> dict:
    """L1 for every group with at least two compiling L0 specs (or only --component)."""
    import req_graph
    from agents.architect_agent import run_group
    graph_path = RUNS_DIR / stem / "graph" / "graph.json"
    if not graph_path.exists():
        stage_graph(stem, args)
    graph = json.loads(graph_path.read_text(encoding="utf-8"))
    l0_dir = l0_run_dir(stem, args)
    specs = json.loads((l0_dir / "specs.json").read_text(encoding="utf-8"))
    l0 = {r["id"]: r["lean_predicate"] for r in specs["results"] if r.get("compiles")}
    texts = {r["id"]: " ".join((r.get("requirement_text") or "").split()) for r in specs["results"]}
    domain_path = req_graph.benchmark_dir(stem) / "Domain.lean"
    domain = domain_path.read_text(encoding="utf-8") if domain_path.exists() else None
    groups = [g for g in graph["groups"] if sum(o in l0 for o in g["operations"]) >= 2]
    if args.component:
        groups = [g for g in graph["groups"] if g["id"] in args.component
                  or set(args.component) & set(g["components"])]
    out_dir = arch_run_dir(stem, args) / "arch"
    out_dir.mkdir(parents=True, exist_ok=True)
    meta = arch_meta(stem, args, graph_path)
    summary = {"meta": meta, "groups": {}}
    for g in groups:
        print(f"[arch] {g['id']}: {sum(o in l0 for o in g['operations'])} operations, "
              f"{'model decomposes' if args.no_graph else ' → '.join(g['order'])}")
        t0 = time.time()
        try:
            r = run_group(graph, g["id"], l0, domain, args.model, no_graph=args.no_graph,
                          mode=args.arch_mode, l0_texts=texts)
        except KeyboardInterrupt:
            raise
        except Exception as e:  # one group must not stop the run
            r = {"arch": "", "record": {"group": g["id"], "verdict": f"crashed: {type(e).__name__}: {e}",
                                        "seconds": round(time.time() - t0, 1)}}
        r["record"]["meta"] = meta
        gdir = out_dir / g["id"]
        gdir.mkdir(parents=True, exist_ok=True)
        (gdir / "Arch.lean").write_text(r["arch"], encoding="utf-8")
        _write_json(gdir / "arch.json", r["record"])
        proved = r["record"].get("proved", {})
        summary["groups"][g["id"]] = {"verdict": r["record"].get("verdict"),
                                      "proved": sum(proved.values()), "obligations": len(proved),
                                      "seconds": r["record"].get("seconds")}
        _write_json(out_dir / "summary.json", summary)
        print(f"[arch] {g['id']}: {r['record'].get('verdict')}, {sum(proved.values())}/{len(proved)} "
              f"obligations proved, {r['record'].get('seconds')}s -> {gdir.relative_to(ROOT)}")
    return summary


def chain_run_dir(stem: str, args) -> Path:
    from chain_pipeline import CHAIN_VERSION
    d = RUNS_DIR / stem / (args.run_name or f"{args.model}-{CHAIN_VERSION}")
    return d / f"rep{args.rep}" if args.repeat else d


def stage_chain(stem: str, args) -> list:
    """Chain L1 + L2 for every accepted spec of the frozen L0 run (see chain_pipeline.py)."""
    import chain_pipeline
    from agents import chain_architect, chain_coder
    l0_dir = l0_run_dir(stem, args)
    if not (l0_dir / "specs.json").exists():
        _fail(f"no L0 run at {l0_dir} (set --l0-run)")
    out_dir = chain_run_dir(stem, args)
    out_dir.mkdir(parents=True, exist_ok=True)
    meta = run_meta(args)
    meta.update(harness_version=chain_pipeline.CHAIN_VERSION, l0_prompt_hash=meta.pop("prompt_hash", None),
                prompt_hash={"architect": chain_architect.prompt_hash(), "coder": chain_coder.prompt_hash()},
                l0_run=str(l0_dir.relative_to(ROOT)) if l0_dir.is_relative_to(ROOT) else str(l0_dir),
                split=args.split, fallback_single=args.fallback_single)
    out = chain_pipeline.run(l0_dir, out_dir, args.model, split=args.split,
                             fallback_single=args.fallback_single, only=args.only, kinds=args.kinds,
                             limit=args.limit, resume=args.resume, meta=meta)
    n = len(out)
    print(f"[chain] {stem}: L1 {sum(e.get('l1', {}).get('success', False) for e in out)}/{n}, "
          f"end to end {sum(e.get('full_check') is True for e in out)}/{n} -> "
          f"{out_dir.relative_to(ROOT) if out_dir.is_relative_to(ROOT) else out_dir}")
    return out


def stage_code(stem: str, args) -> dict:
    """L2 for every group with an accepted L1 Arch.lean (or only --component)."""
    import code_lean as CL
    from agents.coding_agent import run_component_coder
    from lean_runner import check_lean

    if getattr(args, "arch_run", None):
        arch_dir = Path(args.arch_run).resolve()
        if not arch_dir.exists():
            _fail(f"arch run directory not found: {arch_dir}")
    else:
        arch_dir = arch_run_dir(stem, args) / "arch"
        if not arch_dir.exists():
            stage_arch(stem, args)
            arch_dir = arch_run_dir(stem, args) / "arch"

    out_dir = code_run_dir(stem, args) / "code"
    out_dir.mkdir(parents=True, exist_ok=True)

    meta = run_meta(args)
    arch_rel = str(arch_dir.relative_to(ROOT)) if arch_dir.is_relative_to(ROOT) else str(arch_dir)
    meta.update(harness_version=L2_VERSION, arch_run=arch_rel)
    summary = {"meta": meta, "groups": {}}
    _write_json(out_dir / "summary.json", summary)

    group_dirs = sorted([d for d in arch_dir.iterdir() if d.is_dir() and (d / "Arch.lean").exists()])
    if args.component:
        filtered = []
        for d in group_dirs:
            if d.name in args.component:
                filtered.append(d)
            elif (d / "arch.json").exists():
                rec = json.loads((d / "arch.json").read_text(encoding="utf-8"))
                comps = rec.get("order") or list((rec.get("contracts") or {}).keys())
                if set(args.component) & set(comps):
                    filtered.append(d)
        group_dirs = filtered

    for gdir in group_dirs:
        group_id = gdir.name
        t0 = time.time()
        g_out = out_dir / group_id
        g_out.mkdir(parents=True, exist_ok=True)
        try:
            arch_code = (gdir / "Arch.lean").read_text(encoding="utf-8")
            arch_json_path = gdir / "arch.json"
            arch_rec = json.loads(arch_json_path.read_text(encoding="utf-8")) if arch_json_path.exists() else {}

            if arch_rec.get("verdict") not in ("accepted", "accepted-degraded", None):
                print(f"[code] {group_id}: skipped (L1 verdict: {arch_rec.get('verdict')})")
                continue

            comps = arch_rec.get("order") or []
            contracts = arch_rec.get("contracts") or {}
            all_ops = list(arch_rec.get("operations", {}).keys())
            if not all_ops:
                all_ops = [op for c in contracts.values() for op in (c.get("ops") or {}).keys()]

            print(f"[code] {group_id}: implementing {len(comps)} components ({' → '.join(comps)})")
            comp_results = {}
            comp_codes = []
            all_comps_ok = True

            for comp in comps:
                owned = list((contracts.get(comp, {}).get("ops") or {}).keys())
                res = run_component_coder(
                    group=group_id,
                    comp=comp,
                    owned=owned,
                    all_ops=all_ops,
                    locked_context=arch_code,
                    model=args.model,
                    skip_lean=args.skip_lean,
                )
                comp_results[comp] = res
                if res.get("success"):
                    comp_codes.append(res.get("code", "").strip())
                else:
                    all_comps_ok = False

            if comps:
                system_impl = CL.system_impl_def(group_id, comps)
                sound_inst = CL.system_sound_instantiation(group_id, comps)
            else:
                system_impl = ""
                sound_inst = ""

            full_impl = "\n\n".join([arch_code.strip()] + comp_codes + ([system_impl, sound_inst] if system_impl else [])) + "\n"
            (g_out / "Impl.lean").write_text(full_impl, encoding="utf-8")

            if not args.skip_lean and all_comps_ok and comps:
                check = check_lean(full_impl)
                sound_proved = check.get("success", False)
                impl_compiles = check.get("success", False)
                err = check.get("error", "")
            else:
                sound_proved = all_comps_ok if args.skip_lean else False
                impl_compiles = all_comps_ok
                err = ""

            verdict = "accepted" if (all_comps_ok and sound_proved) else "rejected"
            elapsed = round(time.time() - t0, 1)
            rec = {
                "group": group_id,
                "verdict": verdict,
                "impl_compiles": impl_compiles,
                "sound_proved": sound_proved,
                "seconds": elapsed,
                "components": comp_results,
                "error": err,
                "meta": meta,
            }
        except KeyboardInterrupt:
            raise
        except Exception as e:
            elapsed = round(time.time() - t0, 1)
            verdict = f"crashed: {type(e).__name__}: {e}"
            rec = {
                "group": group_id,
                "verdict": verdict,
                "impl_compiles": False,
                "sound_proved": False,
                "seconds": elapsed,
                "components": {},
                "error": str(e),
                "meta": meta,
            }
        _write_json(g_out / "code.json", rec)

        summary["groups"][group_id] = {
            "verdict": verdict,
            "impl_compiles": rec.get("impl_compiles", False),
            "sound_proved": rec.get("sound_proved", False),
            "seconds": elapsed,
        }
        _write_json(out_dir / "summary.json", summary)
        print(f"[code] {group_id}: {verdict}, compiles={rec.get('impl_compiles')}, sound={rec.get('sound_proved')}, {elapsed}s -> {g_out.relative_to(ROOT) if g_out.is_relative_to(ROOT) else g_out}")

    return summary


# ---------------------------------------------------------------------------

def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description="ContractForge pipeline")
    ap.add_argument("inputs", nargs="*", help="requirements .xml or parsed .json (default: Requirements/*.xml)")
    ap.add_argument("--until", choices=STAGES, default=DEFAULT_UNTIL,
                    help="last stage to run (default: %(default)s); `chain` runs the per-spec L1 + L2 path")
    ap.add_argument("--model", default=os.getenv("CF_MODEL", "qwen"),
                    help="qwen | deepseek | groq | gemma (default: $CF_MODEL or qwen)")
    ap.add_argument("--run-name", help="output folder under runs/<doc>/ (default: the model name)")
    ap.add_argument("--limit", type=int, help="only the first N entries")
    ap.add_argument("--only", nargs="+", metavar="ID", help="only these entry ids")
    ap.add_argument("--kinds", nargs="+", choices=["requirement", "data_constraint", "use_case"])
    ap.add_argument("--resume", action="store_true", help="skip entries already done in a previous run")
    ap.add_argument("--skip-lean", action="store_true", help="do not type-check (specs marked unchecked)")
    ap.add_argument("--on-l0-fail", choices=["stop", "redo", "exclude"], default="stop",
                    help="entries failing L0.5: stop before L1 (default), redo them once, or exclude them")
    ap.add_argument("--repeat", type=int, metavar="N",
                    help="run N times with seeds CF_SEED, CF_SEED+1, …; outputs in "
                         "runs/<doc>/<model>-<version>/rep<k>/")
    ap.add_argument("--l0-run", help="L1: frozen L0 run folder with specs.json "
                                       "(default runs/<doc>/qwen-v10.1/rep1)")
    ap.add_argument("--arch-run", help="L2: frozen L1 run folder with arch/ "
                                       "(default runs/<doc>/<model>-L1-v1/rep<k>/arch)")
    ap.add_argument("--component", nargs="+", metavar="ID", help="L1: only these groups (or groups "
                                                                   "containing these components)")
    ap.add_argument("--no-graph", action="store_true",
                    help="L1 baseline: the model decomposes each group itself (no components/edges/order)")
    ap.add_argument("--arch-mode", choices=["pipeline", "agent"], default=os.getenv("CF_ARCH_MODE", "pipeline"),
                    help="L1: the harness calls the tools (pipeline) or the model does (agent)")
    ap.add_argument("--vocab", choices=["full", "srs"], default=None,
                    help="graph: full = also use benchmark/<doc>/Domain.lean and the synonyms file when "
                         "they exist (default); srs = only the SRS and the L0 specs")
    ap.add_argument("--split", choices=["auto", "always", "never"], default="auto",
                    help="chain: split specs into two components (auto: not the single-step ones)")
    ap.add_argument("--fallback-single", action="store_true",
                    help="chain: when the two-component split fails, implement `Spec` as one component "
                         "(reported separately as single-fallback)")
    args = ap.parse_args(argv)
    if args.repeat is not None and args.repeat < 1:
        _fail("--repeat must be at least 1")

    paths = [Path(p).resolve() for p in args.inputs] or sorted(REQ_DIR.glob("*.xml"))
    if not paths:
        _fail(f"no requirements XML found in {REQ_DIR}")
    chain = args.until == "chain"
    l2 = args.until in L2_STAGES
    l1 = (args.until in L1_STAGES) or l2
    run_spec_stage = not l1 and not chain and STAGES.index(args.until) >= STAGES.index("spec")
    if run_spec_stage or args.until in ("arch", "code", "chain"):
        preflight(args.model, args.skip_lean)

    from llm import set_seed
    for path in paths:
        if chain:  # L0 is frozen; no graph needed
            for k in range(1, (args.repeat or 1) + 1):
                args.rep = k
                set_seed(SEED + k - 1)
                if args.repeat:
                    print(f"[repeat] {path.stem}: chain repetition {k}/{args.repeat}, seed {SEED + k - 1}")
                stage_chain(path.stem, args)
            continue
        if l1:  # L0 is frozen: read the parsed JSON and the L0 run, never regenerate them
            if not (PARSED_DIR / f"{path.stem}.json").exists():
                stage_parse(path)
            graph_path = RUNS_DIR / path.stem / "graph" / "graph.json"
            # `--until graph` always rebuilds (deterministic, no model); later stages reuse the
            # graph on disk so a run stays comparable with the graph it was started with.
            if args.until == "graph" or not graph_path.exists():
                stage_graph(path.stem, args)
            else:
                import req_graph
                have = json.loads(graph_path.read_text(encoding="utf-8")).get("graph_version")
                if have != req_graph.GRAPH_VERSION:
                    print(f"[graph] warning: {graph_path.relative_to(ROOT)} was built by graph version {have}, "
                          f"the code is version {req_graph.GRAPH_VERSION}; rebuild it with --until graph")
            if args.until == "graph":
                continue
            for k in range(1, (args.repeat or 1) + 1):
                args.rep = k
                set_seed(SEED + k - 1)
                if args.repeat:
                    print(f"[repeat] {path.stem}: {'L2' if l2 else 'L1'} repetition {k}/{args.repeat}, seed {SEED + k - 1}")
                if args.until in L1_STAGES:
                    stage_arch(path.stem, args)
                elif args.until == "code":
                    stage_code(path.stem, args)
            continue
        doc = stage_parse(path)
        for k in range(1, (args.repeat or 1) + 1):
            args.rep = k
            set_seed(SEED + k - 1)
            if args.repeat:
                print(f"[repeat] {path.stem}: repetition {k}/{args.repeat}, seed {SEED + k - 1}")
            if run_spec_stage:
                stage_spec(doc, path.stem, args)
            if STAGES.index(args.until) >= STAGES.index("check") and not args.skip_lean:
                stage_check(doc, path.stem, args)
    return 0


if __name__ == "__main__":
    sys.exit(main())
