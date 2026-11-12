"""Chain path: per accepted L0 spec, L1 (agents/chain_architect.py) then L2 (agents/chain_coder.py),
then one Lean file per spec with the end-to-end theorem.

Used by `main.py --until chain` (one output folder per repetition) and by `e2e_l1l2.py`
(the older CLI; supports shards for parallel jobs). Outputs in `out_dir`:

    l1l2[.<a>-<b>].json   one record per spec, rewritten after every spec
    l1l2/<id>.lean        spec + architecture + implementations + `system_ok`

A record:
    l1   success, mode ("chain" two components | "single" not split | "single-fallback" the
         split failed and --fallback-single is on), attempts, contracts, strength
         (chain_checks), error + error_class (chain_failures), stages, code
    l2   per contract: success, attempts, error + error_class, stages, code
    full_check   Lean accepts the whole file including
                 `theorem system_ok : Spec.Satisfies (<B>Impl ∘ <A>Impl)`   (chain)
                 `theorem system_ok : Spec.Satisfies SpecImpl`              (single)
                 proved from PO1/PO2/PO3 with the framework's soundness theorems
"""
import json
import re
import time
import traceback
from pathlib import Path
from typing import List, Optional

from agents.chain_architect import run_architect, single_architecture
from agents.chain_coder import run_coder
from chain_failures import classify, root_cause
from lean_runner import HEADER, check_lean

CHAIN_VERSION = "chain-v3"


def system_theorem(contracts: List[str]) -> str:
    """End-to-end statement from the proved obligations (Soundness.lean)."""
    if len(contracts) == 1:
        return ("theorem system_ok : Spec.Satisfies SpecImpl :=\n"
                "  Contract.refines_sound po2 SpecImpl_ok")
    a, b = contracts
    return (f"theorem system_ok : Spec.Satisfies ({b}Impl ∘ {a}Impl) :=\n"
            f"  Contract.system_sound po1 po2 {a}Impl_ok {b}Impl_ok")


def _l1_record(arch: dict) -> dict:
    err = (arch.get("error") or "")
    stages = [x.get("stage") for x in arch.get("log", [])]
    return {"success": arch["success"], "mode": arch.get("mode", "chain"), "attempts": arch["attempts"],
            "contracts": arch.get("contracts") or [], "strength": arch.get("strength"),
            "error": err[:1500], "error_class": classify(err, stages), "stages": stages,
            **({"why_single": arch["why_single"]} if arch.get("why_single") else {}),
            "code": arch.get("code") or ""}


def run_entry(r: dict, model: str, split: str = "auto", fallback_single: bool = False) -> dict:
    """L1 + L2 + the end-to-end check for one L0 result `r` (a specs.json entry)."""
    sid, spec = r["id"], r["lean_predicate"]
    e = {"id": sid, "kind": r["kind"], "requirement_text": r["requirement_text"]}
    t0 = time.time()
    try:
        arch = run_architect(spec, model, kind=r.get("kind"), split=split)
        e["l1"] = _l1_record(arch)
        if not arch["success"] and fallback_single:
            failed = e["l1"]
            e["l1"] = _l1_record(single_architecture("the two-component split failed"))
            e["l1"].update(mode="single-fallback", attempts=failed["attempts"],
                           failed_split={k: failed[k] for k in ("error", "error_class", "stages", "code")})
        e["l2"] = []
        l1 = e["l1"]
        if l1["success"]:
            locked = spec + "\n\n" + l1["code"]
            for c in l1["contracts"]:
                res = run_coder(c, locked, model)
                err = res.get("error") or ""
                stages = [x.get("stage") for x in res.get("log", [])]
                e["l2"].append({"contract": c, "success": res["success"], "attempts": res["attempts"],
                                "error": err[:1500], "error_class": classify(err, stages),
                                "stages": stages, "code": res.get("code") or ""})
            if e["l2"] and all(x["success"] for x in e["l2"]):
                e["system_theorem"] = system_theorem(l1["contracts"])
                full = "\n\n".join([locked] + [x["code"] for x in e["l2"]] + [e["system_theorem"]])
                e["full_check"] = check_lean(full)["success"]
            else:
                cause = root_cause(e)
                if cause:
                    e["l2_root_cause"] = cause
    except KeyboardInterrupt:
        raise
    except Exception as ex:  # one spec must not stop the run
        e["crash"] = f"{type(ex).__name__}: {ex}\n{traceback.format_exc()[-1500:]}"
    e["seconds"] = round(time.time() - t0, 1)
    return e


def lean_file(r: dict, e: dict) -> str:
    """The spec, its architecture and implementations as one file (compiles from the repo
    root when `full_check` is true; failed parts are kept so they can be read)."""
    text = " ".join((r.get("requirement_text") or "").split())
    parts = [f"-- {r['id']}: {text}", "-- L0 spec", r["lean_predicate"]]
    l1 = e.get("l1")
    if l1:
        parts += [f"-- L1 architecture (mode={l1['mode']}, success={l1['success']})", l1["code"]]
    for x in e.get("l2", []):
        parts += [f"-- L2 {x['contract']} (success={x['success']})", x["code"]]
    if e.get("system_theorem"):
        parts += [f"-- end to end (checked={e.get('full_check')})", e["system_theorem"]]
    return HEADER + "\n\n".join(p for p in parts if p) + "\n"


def accepted_specs(l0_dir: Path) -> List[dict]:
    """L0 results that passed every check and were accepted in review.json (all checked ones
    if there is no review.json)."""
    specs = json.loads((l0_dir / "specs.json").read_text(encoding="utf-8"))
    review_path = l0_dir / "review.json"
    review = json.loads(review_path.read_text(encoding="utf-8")) if review_path.exists() else None
    return [r for r in specs["results"] if r.get("checked") is True
            and (review is None or review.get(r["id"], {}).get("decision") == "accept")]


def run(l0_dir: Path, out_dir: Path, model: str, *, split: str = "auto", fallback_single: bool = False,
        only: Optional[List[str]] = None, kinds: Optional[List[str]] = None, limit: Optional[int] = None,
        start: int = 0, end: Optional[int] = None, resume: bool = False, meta: Optional[dict] = None) -> List[dict]:
    todo = accepted_specs(l0_dir)
    total = len(todo)
    if kinds:
        todo = [r for r in todo if r["kind"] in kinds]
    if only:
        todo = [r for r in todo if r["id"] in only]
    if limit:
        todo = todo[:limit]
    todo = todo[start:end]
    shard = f".{start}-{end}" if (start or end) else ""
    out_path, lean_dir = out_dir / f"l1l2{shard}.json", out_dir / "l1l2"
    lean_dir.mkdir(parents=True, exist_ok=True)
    done = {}
    if resume and out_path.exists():
        done = {e["id"]: e for e in json.loads(out_path.read_text(encoding="utf-8"))
                if "crash" not in e}
    if meta is not None:
        (out_dir / "chain_meta.json").write_text(json.dumps(meta, indent=2) + "\n", encoding="utf-8")
    print(f"[chain] {l0_dir}: {len(todo)} of {total} accepted specs -> {out_path}", flush=True)
    out = []
    for i, r in enumerate(todo, 1):
        e = done.get(r["id"]) or run_entry(r, model, split=split, fallback_single=fallback_single)
        out.append(e)
        (lean_dir / (re.sub(r"[^\w.-]", "_", r["id"]) + ".lean")).write_text(lean_file(r, e), encoding="utf-8")
        tmp = out_path.with_suffix(".tmp")
        tmp.write_text(json.dumps(out, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        tmp.replace(out_path)
        l1, l2s = e.get("l1", {}), e.get("l2", [])
        print(f"[chain {i}/{len(todo)}] {r['id']}: L1={'OK' if l1.get('success') else 'FAIL'}"
              f"({l1.get('mode')}, {l1.get('attempts')}) L2={sum(x['success'] for x in l2s)}/{len(l2s)} "
              f"end-to-end={e.get('full_check')} {'CRASH ' if 'crash' in e else ''}{e['seconds']}s"
              + (" (kept)" if r["id"] in done else ""), flush=True)
    return out
