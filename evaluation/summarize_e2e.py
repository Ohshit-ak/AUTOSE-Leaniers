"""Summarize an L1/L2 run: python evaluation/summarize_e2e.py <run_dir> [...]"""
import collections, json, re, sys
from pathlib import Path

_POST = re.compile(r"post\s*:=\s*fun\s+\w+\s+\w+\s*=>\s*(.*?)(?=\n\S|\n\s*(?:pre|post)\s*:=|\Z)", re.S)


def trivial(code: str) -> bool:
    """First component's post only copies fields (m.x = i.x ∧ …): a pass-through split."""
    posts = _POST.findall(code)
    if not posts:
        return False
    parts = [p.strip() for p in re.split(r"∧", posts[0]) if p.strip()]
    return all(re.fullmatch(r"\(?\w+\.(\w+)\s*=\s*\w+\.\1\)?", p) for p in parts)


for run in sys.argv[1:]:
    d = json.loads((Path(run) / "l1l2.json").read_text())
    n = len(d)
    l1 = sum(e.get("l1", {}).get("success", False) for e in d)
    l2s = [x for e in d for x in e.get("l2", [])]
    l2 = sum(x["success"] for x in l2s)
    full = sum(e.get("full_check") is True for e in d)
    kinds = collections.Counter((e["kind"], e.get("full_check") is True) for e in d)
    att = sum(e["l1"]["attempts"] for e in d if "l1" in e) / max(n, 1)
    mins = sum(e["seconds"] for e in d) / 60
    print(f"{run}: {n} specs · L1 {l1}/{n} · L2 components {l2}/{len(l2s)} · "
          f"end-to-end (L1 + all L2 + full Lean check) {full}/{n} · L1 attempts {att:.2f} · {mins:.0f} min")
    for k in sorted({k for k, _ in kinds}):
        print(f"   {k}: {kinds[(k, True)]}/{kinds[(k, True)] + kinds[(k, False)]} end-to-end")
    ok = [e for e in d if e.get("full_check") is True]
    triv = [e["id"] for e in ok if trivial(e["l1"]["code"])]
    print(f"   of the end-to-end passes, {len(triv)} have a pass-through first component: {triv}")
    print("   failing L1:", [e["id"] for e in d if not e.get("l1", {}).get("success")])
