"""Drive L1 (architect) + L2 (coders) over the L0 specs that L0.5 accepted.

Usage (from harness/): python e2e_l1l2.py <run_dir> [--model qwen] [--limit N]
Writes <run_dir>/l1l2.json (rewritten after every entry) and <run_dir>/l1l2/<id>.lean.
"""
import argparse, json, re, sys, time, traceback
from pathlib import Path

sys.path.insert(0, str(Path.cwd()))
from agents.architect_agent import run_architect, extract_contracts
from agents.coding_agent import run_coder
from lean_runner import check_lean

TOP_DEF = re.compile(r"^(?:def|structure|inductive|abbrev|theorem|lemma)\s+([\w.]+)", re.M)
SPEC_NAMES = {"Input", "Output", "Spec"}


def static_l1(code, contracts):
    issues = []
    if not contracts:
        issues.append("no `...Contract` definitions found")
    redefs = SPEC_NAMES & set(TOP_DEF.findall(code))
    if redefs:
        issues.append(f"redefines locked spec names: {sorted(redefs)}")
    if "sorry" in code:
        issues.append("contains sorry")
    if len(contracts) >= 2 and "Compatible" not in code:
        issues.append("PO1 not stated (no `Compatible` theorem)")
    if not re.search(r"Refines[^\n]*Spec", code):
        issues.append("PO2 not stated (no `Refines ... Spec` theorem)")
    if len(contracts) >= 2 and ".seq" not in code and "seq " not in code:
        issues.append("contracts never composed with `seq`")
    if re.search(r"pre\s*:=\s*fun\s+\w+\s*=>\s*True\s*$", code, re.M) and \
       re.search(r"post\s*:=\s*fun\s+\w+\s+\w+\s*=>\s*True\s*$", code, re.M):
        issues.append("some contract has trivial pre and post (True/True)")
    return issues


def static_l2(code, name):
    issues = []
    if not re.search(rf"{re.escape(name)}\s*\)?\s*\.Satisfies|Satisfies\s+{re.escape(name)}", code):
        issues.append(f"PO3 not stated (no `{name}.Satisfies` theorem)")
    redefs = (SPEC_NAMES | {name}) & set(TOP_DEF.findall(code))
    if redefs:
        issues.append(f"redefines locked names: {sorted(redefs)}")
    return issues


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("run_dir")
    ap.add_argument("--model", default="qwen")
    ap.add_argument("--limit", type=int)
    a = ap.parse_args()
    run = Path(a.run_dir)
    specs = json.loads((run / "specs.json").read_text())
    review = json.loads((run / "review.json").read_text())
    todo = [r for r in specs["results"]
            if r.get("checked") is True and review.get(r["id"], {}).get("decision") == "accept"]
    if a.limit:
        todo = todo[:a.limit]
    print(f"[l1l2] {run}: {len(todo)} accepted specs of {len(specs['results'])}", flush=True)

    from main import ensure_qwen_server
    if a.model == "qwen":
        ensure_qwen_server()

    out_path, lean_dir = run / "l1l2.json", run / "l1l2"
    lean_dir.mkdir(exist_ok=True)
    out = []
    for i, r in enumerate(todo, 1):
        sid, spec = r["id"], r["lean_predicate"]
        e = {"id": sid, "kind": r["kind"], "requirement_text": r["requirement_text"]}
        t0 = time.time()
        try:
            arch = run_architect(spec, a.model)
            contracts = extract_contracts(arch["code"])
            e["l1"] = {"success": arch["success"], "attempts": arch["attempts"],
                       "error": (arch.get("error") or "")[:1500], "contracts": contracts,
                       "stages": [x.get("stage") for x in arch.get("log", [])],
                       "static_issues": static_l1(arch["code"], contracts) if arch["code"] else ["empty"],
                       "code": arch["code"]}
            e["l2"] = []
            if arch["success"]:
                locked = spec + "\n\n" + arch["code"]
                for c in contracts:
                    res = run_coder(c, locked, a.model)
                    e["l2"].append({"contract": c, "success": res["success"], "attempts": res["attempts"],
                                    "error": (res.get("error") or "")[:1500],
                                    "stages": [x.get("stage") for x in res.get("log", [])],
                                    "static_issues": static_l2(res["code"], c), "code": res["code"]})
                if e["l2"] and all(x["success"] for x in e["l2"]):
                    full = locked + "\n\n" + "\n\n".join(x["code"] for x in e["l2"])
                    e["full_check"] = check_lean(full)["success"]
        except Exception as ex:
            e["crash"] = f"{type(ex).__name__}: {ex}\n{traceback.format_exc()[-1500:]}"
        e["seconds"] = round(time.time() - t0, 1)
        out.append(e)
        safe = re.sub(r"[^\w.-]", "_", sid)
        parts = [f"-- {sid}: {r['requirement_text']}", "-- L0 spec", spec]
        if e.get("l1"):
            parts += [f"-- L1 architect (success={e['l1']['success']})", e["l1"]["code"]]
        for x in e.get("l2", []):
            parts += [f"-- L2 {x['contract']} (success={x['success']})", x["code"]]
        (lean_dir / f"{safe}.lean").write_text("import ContractForge\nopen ContractForge\n\n" + "\n\n".join(parts))
        out_path.write_text(json.dumps(out, indent=2, ensure_ascii=False))
        l1 = e.get("l1", {})
        l2s = e.get("l2", [])
        print(f"[l1l2 {i}/{len(todo)}] {sid}: L1={'OK' if l1.get('success') else 'FAIL'}"
              f"({l1.get('attempts')}) contracts={len(l1.get('contracts', []))} "
              f"L2={sum(x['success'] for x in l2s)}/{len(l2s)} full={e.get('full_check')} "
              f"{'CRASH ' if 'crash' in e else ''}{e['seconds']}s", flush=True)
    print("[l1l2] done", flush=True)


if __name__ == "__main__":
    main()
