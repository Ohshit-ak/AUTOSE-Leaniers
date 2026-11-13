"""Compare an L0 run made with `--on-l0-fail loop` against a baseline L0 run (same prompt, no loop).

Usage:
    python evaluation/summarize_l05loop.py <loop L0 rep dir> <baseline L0 rep dir> [-o out.md]

Prints markdown: L0.5 status counts, entries that the loop changed, and loop rounds per entry.
"""
import argparse
import collections
import json
from pathlib import Path

ORDER = ["pass", "flag", "fail"]


def load(d: Path) -> dict:
    return {r["id"]: r for r in json.loads((d / "specs.json").read_text(encoding="utf-8"))["results"]}


def status(r: dict | None) -> str:
    return (r or {}).get("l05", {}).get("status", "missing")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("loop", type=Path)
    ap.add_argument("base", type=Path)
    ap.add_argument("-o", type=Path)
    a = ap.parse_args()
    loop, base = load(a.loop), load(a.base)

    looped = {i: r for i, r in loop.items() if r.get("l05_rounds")}
    # Before the loop: every regenerated entry was a fail; nothing else is touched by the loop.
    cb = collections.Counter(status(r) for r in base.values())
    cp = collections.Counter("fail" if i in looped else status(r) for i, r in loop.items())
    cl = collections.Counter(status(r) for r in loop.values())
    out = [f"## L0.5 loop: `{a.loop}` vs `{a.base}`", "",
           "| L0.5 status | baseline run | this run, before loop | this run, after loop |",
           "|---|---|---|---|"]
    for s in ORDER:
        out.append(f"| {s} | {cb[s]} | {cp[s]} | {cl[s]} |")
    out.append(f"| **total** | {len(base)} | {len(loop)} | {len(loop)} |")
    out.append(f"| into L1 (pass + flag) | {cb['pass'] + cb['flag']} | {cp['pass'] + cp['flag']} | "
               f"{cl['pass'] + cl['flag']} |")
    out += ["", f"### Entries the loop regenerated ({len(looped)})", "",
            "| entry | kind | rounds | final status | baseline status | remaining problems |",
            "|---|---|---|---|---|---|"]
    for i, r in sorted(looped.items()):
        probs = "; ".join(r["l05"]["problems"]) or "—"
        out.append(f"| {i} | {r.get('kind', '')} | {r['l05_rounds']} | {status(r)} | "
                   f"{status(base.get(i))} | {probs} |")
    fixed = sum(status(r) != "fail" for r in looped.values())
    out += ["", f"Loop fixed {fixed} of {len(looped)} regenerated entries.", ""]

    both = sorted(set(loop) & set(base))
    trans = collections.Counter((status(base[i]), status(loop[i])) for i in both)
    out += ["### Per-entry status, baseline → loop run (same entries)", "",
            "| baseline → loop | entries |", "|---|---|"]
    for (b, l), n in sorted(trans.items(), key=lambda kv: (ORDER.index(kv[0][0]) if kv[0][0] in ORDER else 9,
                                                         ORDER.index(kv[0][1]) if kv[0][1] in ORDER else 9)):
        out.append(f"| {b} → {l} | {n} |")
    only = sorted(set(loop) ^ set(base))
    if only:
        out += ["", "Entries in only one run: " + ", ".join(only)]
    text = "\n".join(out) + "\n"
    if a.o:
        a.o.write_text(text, encoding="utf-8")
    print(text)


if __name__ == "__main__":
    main()
