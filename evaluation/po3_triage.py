"""P1 triage of stored PO3 failures (no model; Lean only).

Every L2 component with error_class `po3` in the given chain runs is sorted into

    tactics              CF_PO3_TACTICS=2 proves it (stronger proof scripts), or no input among those
                         tried violates `post` (the proof, not the code, is the problem as far as the
                         search can tell)
    wrong-code           a concrete input on which the implementation violates `post`, and an output
                         that `post` accepts for that input
    unsatisfiable-spec   a concrete input satisfying `pre` for which no candidate output satisfies
                         `post` (search-based: "no output found", not a proof), or the failing
                         conjunct does not mention the output once fixed outputs are substituted
    unevaluable          the predicates are not decidable / no literal could be built

Distinct (contract, implementation) pairs are triaged once and the class is counted per
occurrence. The second component of a two-component chain (it consumes `Mid`) is reported apart.

    python evaluation/po3_triage.py "runs/*/qwen-chain-v5" "runs/*/qwen-chain-v5-fallback" \
        -o docs/analysis/po3_triage.md --jobs 16
"""
import argparse
import glob
import hashlib
import json
import os
import sys
from collections import Counter, defaultdict
from concurrent.futures import ProcessPoolExecutor
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "harness"))
CWD = Path.cwd()  # captured before the chdir so relative CLI paths resolve where the user ran the script
os.chdir(ROOT / "harness")


def _l0_specs(run_dir: Path) -> dict:
    meta = json.loads((run_dir / "chain_meta.json").read_text()) if (run_dir / "chain_meta.json").exists() else {}
    l0 = ROOT / meta.get("l0_run", "") if meta.get("l0_run") else None
    if not l0 or not (l0 / "specs.json").exists():
        return {}
    return {r["id"]: r["lean_predicate"] for r in json.loads((l0 / "specs.json").read_text())["results"]}


def cases(patterns):
    out = []
    for pat in patterns:
        for d in sorted(glob.glob(str(ROOT / pat))):
            for rep in sorted(Path(d).glob("rep*")):
                f = rep / "l1l2.json"
                if not f.exists():
                    continue
                specs = _l0_specs(rep)
                for e in json.loads(f.read_text()):
                    l1 = e.get("l1") or {}
                    for k, x in enumerate(e.get("l2", [])):
                        if x.get("error_class") != "po3" or e["id"] not in specs:
                            continue
                        out.append({"doc": Path(d).parent.name, "run": Path(d).name, "rep": rep.name,
                                    "id": e["id"], "mode": l1.get("mode"), "contract": x["contract"],
                                    "position": "second" if (l1.get("mode") == "chain" and k == 1) else
                                                ("first" if l1.get("mode") == "chain" else "single"),
                                    "spec": specs[e["id"]], "arch": l1.get("code") or "", "impl": x.get("code") or ""})
    return out


def _key(c):
    return hashlib.sha256("\0".join([c["spec"], c["arch"], c["contract"], c["impl"]]).encode()).hexdigest()[:16]


def triage_one(c):
    os.environ["CF_PO3_TACTICS"] = "2"
    import chain_checks as C
    import counterexample as X
    import po
    from agents import chain_coder as CC
    from validate import field_types
    locked = c["spec"] + "\n\n" + c["arch"]
    contract = next((k for k in C.parse_contracts(locked) if k.name == c["contract"]), None)
    impl = c["contract"] + "Impl"
    code = C.strip_theorems(c["impl"])
    if not code.strip() or contract is None:
        return {"class": "unevaluable", "why": "no implementation code or contract stored"}
    prefix = C.strip_theorems(C.strip_examples(locked)) + "\n\n" + code
    defs = [n for n in __import__("re").findall(r"^def\s+([\w.']+)", code, __import__("re").M)]
    unfold = ", ".join(dict.fromkeys([contract.name] + defs))
    try:
        proof, _ = po.prove(prefix, po.po3_statement(contract.name, impl), CC.po3_proofs(unfold, contract,
                                                                                        field_types(locked))[2:])
    except Exception as ex:  # noqa: BLE001
        proof = None
    if proof:
        return {"class": "tactics", "why": "proved with CF_PO3_TACTICS=2"}
    try:
        t = X.triage(prefix, contract, impl, seed_code=c["spec"])
    except Exception as ex:  # noqa: BLE001
        return {"class": "unevaluable", "why": f"{type(ex).__name__}: {ex}"[:200]}
    if t["class"] == "tactics":
        t["why"] = "no counterexample among the inputs tried"
    return t


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("runs", nargs="+")
    ap.add_argument("-o", "--out", default=str(ROOT / "docs/analysis/po3_triage.md"))
    ap.add_argument("--jobs", type=int, default=8)
    args = ap.parse_args()
    cs = cases(args.runs)
    uniq = {}
    for c in cs:
        uniq.setdefault(_key(c), c)
    print(f"{len(cs)} PO3 failures, {len(uniq)} distinct", flush=True)
    keys = list(uniq)
    with ProcessPoolExecutor(args.jobs) as ex:
        res = dict(zip(keys, ex.map(triage_one, [uniq[k] for k in keys])))
    args.out = str(CWD / args.out)  # no-op if already absolute
    Path(args.out).parent.mkdir(parents=True, exist_ok=True)
    out_json = Path(args.out).with_suffix(".json")
    out_json.write_text(json.dumps([{**{k: v for k, v in uniq[key].items() if k not in ("spec", "arch", "impl")},
                                     **res[key]} for key in keys], indent=1, ensure_ascii=False))

    lines = ["# P1: triage of stored PO3 failures", "",
             f"Runs: {', '.join(args.runs)}. {len(cs)} failing components ({len(uniq)} distinct contract + "
             "implementation pairs). Generated by `evaluation/po3_triage.py` (Lean only, no model).", "",
             "Classes: **tactics** = proved by the stronger CF_PO3_TACTICS=2 scripts, or no counterexample found; "
             "**wrong-code** = Lean evaluated the function on a concrete input that satisfies `pre` and `post` "
             "rejected the result, and found an output `post` accepts; **unsatisfiable-spec** = for such an input no "
             "candidate output satisfies `post` (a search, not a proof); **unevaluable** = predicates not "
             "decidable or no literal could be built.", ""]
    by_run = defaultdict(Counter)
    by_pos = defaultdict(Counter)
    by_doc = defaultdict(Counter)
    for c in cs:
        cl = res[_key(c)]["class"]
        by_run[c["run"]][cl] += 1
        by_pos[c["position"]][cl] += 1
        by_doc[c["doc"]][cl] += 1
    classes = ["wrong-code", "unsatisfiable-spec", "tactics", "unevaluable"]
    distinct = Counter(r["class"] for r in res.values())
    lines += ["## Distinct pairs", "", "| class | distinct |", "|---|---|"]
    lines += [f"| {k} | {distinct.get(k, 0)} |" for k in classes] + [""]
    tac_proved = sum(1 for r in res.values() if r.get("why") == "proved with CF_PO3_TACTICS=2")
    lines += [f"Of the {distinct.get('tactics', 0)} tactics cases, {tac_proved} are proved by CF_PO3_TACTICS=2.", ""]
    for title, tab in (("By run (occurrences over repetitions)", by_run), ("By position in the chain", by_pos),
                       ("By SRS", by_doc)):
        lines += [f"## {title}", "", "| | " + " | ".join(classes) + " | total |", "|---" * (len(classes) + 2) + "|"]
        for k in sorted(tab):
            lines.append(f"| {k} | " + " | ".join(str(tab[k].get(c, 0)) for c in classes) + f" | {sum(tab[k].values())} |")
        lines.append("")
    lines += ["## Examples", ""]
    for cl in classes[:2]:
        for key in [k for k in keys if res[k]["class"] == cl][:4]:
            c, r = uniq[key], res[key]
            lines.append(f"- **{cl}** {c['doc']} `{c['id']}` `{c['contract']}`: input `{r.get('input', '')}` → "
                         f"`{r.get('output', '')}`" + (f"; post accepts `{r['needed']}`" if r.get("needed") else "")
                         + (f"; false: `{' '.join(r['failing'][0].split())}`" if r.get("failing") else ""))
    Path(args.out).write_text("\n".join(lines) + "\n")
    print("\n".join(lines[:30]))


if __name__ == "__main__":
    main()
