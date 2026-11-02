#!/usr/bin/env python3
"""Compare two pipeline runs of the same SRS and write a Markdown report.

    python scripts/compare_runs.py "runs/0000 - gamma j/qwen-v8" "runs/0000 - gamma j/qwen-v9" [out.md]

Default output: <after>/comparison.md. Reads only each run's specs.json.
"""
import json
import sys
from pathlib import Path

ICON = {"pass": "✅", "flag": "⚠️", "fail": "❌", None: "—"}
RANK = {"fail": 0, "flag": 1, "pass": 2}


def load(run: Path) -> dict:
    return json.loads((run / "specs.json").read_text(encoding="utf-8"))


def l05(r: dict):
    return (r.get("l05") or {}).get("status")


def status(r: dict) -> str:
    if r.get("checked"):
        return "OK"
    return "FAILED" if r.get("compiles") is not None else "unchecked"


def totals(d: dict) -> dict:
    rs = d["results"]
    s, l = d["summary"], d.get("l05_summary") or {}
    n = len(rs) or 1
    return {
        "entries": s["total"],
        "compile": s.get("compiles", s.get("checked")),
        "rejects a bad example": s.get("rejects_bad_example", "—"),
        "L0 OK (checked)": s["checked"],
        "L0 failed": s["failed"],
        "L0.5 ✅ pass": l.get("pass", "—"),
        "L0.5 ⚠️ flag": l.get("flag", "—"),
        "L0.5 ❌ fail": l.get("fail", "—"),
        "first-attempt OK": sum(1 for r in rs if r.get("checked") and r.get("attempts") == 1),
        "mean attempts": round(sum(r.get("attempts", 0) for r in rs) / n, 2),
        "total seconds": round(sum(r.get("seconds", 0) for r in rs)),
    }


def pct(v, total):
    return f"{v} ({100 * v / total:.0f}%)" if isinstance(v, int) and total else str(v)


def reasons(r: dict) -> str:
    v = r.get("l05") or {}
    return "; ".join(v.get("problems", []) + v.get("flags", [])).replace("|", "/")[:200] or "—"


def text(r: dict) -> str:
    return (r.get("requirement_text") or "").replace("|", "/").replace("\n", " ")[:90]


def report(before: Path, after: Path) -> str:
    b, a = load(before), load(after)
    tb, ta = totals(b), totals(a)
    bi = {r["id"]: r for r in b["results"]}
    ai = {r["id"]: r for r in a["results"]}
    common = [k for k in ai if k in bi]
    added = [k for k in ai if k not in bi]
    removed = [k for k in bi if k not in ai]

    out = [f"# Before/after: `{before.name}` → `{after.name}`",
           "", f"Document: `{a['source'].get('file', '')}` · model: `{a['model']}`", "",
           "## Totals", "", f"| | {before.name} | {after.name} | Δ |", "|---|---|---|---|"]
    for k in tb:
        x, y = tb[k], ta[k]
        d = (f"{y - x:+}" if isinstance(x, int) and isinstance(y, int)
             else f"{y - x:+.2f}" if isinstance(x, float) and isinstance(y, (int, float)) else "")
        out.append(f"| {k} | {pct(x, tb['entries']) if k != 'entries' and 'mean' not in k and 'seconds' not in k else x} "
                   f"| {pct(y, ta['entries']) if k != 'entries' and 'mean' not in k and 'seconds' not in k else y} | {d} |")

    def same_set(keys):
        t = {"entries": len(keys)}
        t["L0 OK"] = (sum(bool(bi[k].get("checked")) for k in keys), sum(bool(ai[k].get("checked")) for k in keys))
        t["L0.5 pass"] = (sum(l05(bi[k]) == "pass" for k in keys), sum(l05(ai[k]) == "pass" for k in keys))
        t["L0.5 fail"] = (sum(l05(bi[k]) == "fail" for k in keys), sum(l05(ai[k]) == "fail" for k in keys))
        return t

    s = same_set(common)
    out += ["", f"On the {s['entries']} entries present in both runs: "
            f"L0 OK {s['L0 OK'][0]} → {s['L0 OK'][1]}, "
            f"L0.5 pass {s['L0.5 pass'][0]} → {s['L0.5 pass'][1]}, "
            f"L0.5 fail {s['L0.5 fail'][0]} → {s['L0.5 fail'][1]}."]

    if added or removed:
        out += ["", "## Entries added / removed by the parser", "", "| | Entry | Text | L0.5 |", "|---|---|---|---|"]
        out += [f"| + | `{k}` | {text(ai[k])} | {ICON[l05(ai[k])]} |" for k in added]
        out += [f"| − | `{k}` | {text(bi[k])} | (was {ICON[l05(bi[k])]}) |" for k in removed]

    changed = [k for k in common if l05(bi[k]) != l05(ai[k]) or status(bi[k]) != status(ai[k])]
    better = [k for k in changed if RANK.get(l05(ai[k]), -1) > RANK.get(l05(bi[k]), -1)]
    worse = [k for k in changed if RANK.get(l05(ai[k]), -1) < RANK.get(l05(bi[k]), -1)]
    sideways = [k for k in changed if k not in better and k not in worse]
    for title, keys in (("Improved", better), ("Regressed", worse), ("L0 status changed, same L0.5", sideways)):
        if not keys:
            continue
        out += ["", f"## {title} ({len(keys)})", "",
                f"| Entry | L0 {before.name} → {after.name} | L0.5 | Reasons now |", "|---|---|---|---|"]
        out += [f"| `{k}` | {status(bi[k])} → {status(ai[k])} | {ICON[l05(bi[k])]} → {ICON[l05(ai[k])]} "
                f"| {reasons(ai[k])} |" for k in keys]

    still = [k for k in ai if l05(ai[k]) == "fail"]
    if still:
        out += ["", f"## Failing L0.5 in {after.name} ({len(still)})", "", "| Entry | Text | Reasons |", "|---|---|---|"]
        out += [f"| `{k}` | {text(ai[k])} | {reasons(ai[k])} |" for k in still]
    out += ["", f"Model output varies from run to run, so single-entry flips are noisy; "
            f"compare totals and patterns.", ""]
    return "\n".join(out)


def main(argv):
    before, after = Path(argv[1]), Path(argv[2])
    dest = Path(argv[3]) if len(argv) > 3 else after / "comparison.md"
    dest.write_text(report(before, after), encoding="utf-8")
    print(dest)


if __name__ == "__main__":
    main(sys.argv)
