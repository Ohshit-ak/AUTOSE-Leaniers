#!/usr/bin/env python3
"""Compare two L0 runs of the same SRS, each with one or more repetitions.

    python evaluation/compare_runs.py <dirA> <dirB> [-o report.md]

A run folder is either one repetition (it has specs.json) or a folder of
repetitions rep1/, rep2/, … (each with specs.json), as written by
`main.py --repeat N`. Reads only specs.json (after the check stage, so L0.5
verdicts are in it).

Per metric it prints mean and min–max over the repetitions of each run. A
difference counts as real only if the means differ by more than the spread
(max − min) of either run; with a single repetition there is no spread, so
nothing can be called real.
Per entry it prints how many repetitions passed L0.5 in A and in B.

L1 runs (folders with rep*/arch/ or arch/, written by `main.py --until arch`) get the arch
report instead: compiles, contracts satisfiable / non-vacuous, trace obligations proved,
PO1 proved per consecutive pair, PO2 proved, attempts, tool calls, failures by stage, and
the most common error per stage. A and B may be graph and --no-graph runs.
"""
import argparse
import json
import re
import statistics
import sys
from pathlib import Path


def load_reps(run: Path) -> list:
    if (run / "specs.json").exists():
        return [json.loads((run / "specs.json").read_text(encoding="utf-8"))]
    reps = sorted((p for p in run.glob("rep*/specs.json")),
                  key=lambda p: int("".join(c for c in p.parent.name if c.isdigit()) or 0))
    if not reps:
        sys.exit(f"error: no specs.json in {run} or {run}/rep*/")
    return [json.loads(p.read_text(encoding="utf-8")) for p in reps]


def l05(r: dict):
    return (r.get("l05") or {}).get("status")


def metrics(d: dict) -> dict:
    rs = d["results"]
    n = len(rs)
    att = [r["attempts"] for r in rs if r.get("attempts")]
    return {
        "entries": n,
        "compiles": sum(r.get("compiles") is True for r in rs),
        "checked (L0 OK)": sum(r.get("checked") is True for r in rs),
        "L0.5 pass": sum(l05(r) == "pass" for r in rs),
        "L0.5 flag": sum(l05(r) == "flag" for r in rs),
        "L0.5 fail": sum(l05(r) == "fail" for r in rs),
        "negative: rejects": sum(r.get("rejects_bad_example") is True for r in rs),
        "negative: accepts forbidden": sum(r.get("rejects_bad_example") is False for r in rs),
        "mean attempts": round(sum(att) / len(att), 2) if att else 0,
    }


# For these a lower number is better.
LOWER_BETTER = {"L0.5 flag", "L0.5 fail", "negative: accepts forbidden", "mean attempts"}


def summarize(values: list) -> tuple:
    return statistics.mean(values), min(values), max(values)


def fmt(mean, lo, hi, reps: int) -> str:
    m = f"{mean:.2f}".rstrip("0").rstrip(".")
    return m if reps == 1 else f"{m} ({lo:g}–{hi:g})"


def verdict(name: str, a: tuple, b: tuple, ra: int, rb: int) -> str:
    diff = b[0] - a[0]
    if diff == 0:
        return "same"
    if ra == 1 and rb == 1:
        return "single runs: no spread"
    spread = max(a[2] - a[1], b[2] - b[1])
    if abs(diff) <= spread:
        return "within noise"
    better = diff < 0 if name in LOWER_BETTER else diff > 0
    return "**better**" if better else "**worse**"


def meta_line(reps: list) -> str:
    metas = [d.get("meta") or {} for d in reps]
    if not any(metas):
        return "no metadata (run before v10)"
    keys = ("harness_version", "model_id", "temperature", "prompt_hash", "git_commit")
    first = {k: metas[0].get(k) for k in keys}
    seeds = [m.get("seed") for m in metas]
    return ", ".join(f"{k} `{v}`" for k, v in first.items()) + f", seeds {seeds}"


def report(dir_a: Path, dir_b: Path) -> str:
    A, B = load_reps(dir_a), load_reps(dir_b)
    ra, rb = len(A), len(B)
    ma, mb = [metrics(d) for d in A], [metrics(d) for d in B]
    out = [f"# `{dir_a.name}` ({ra} rep{'s' * (ra > 1)}) → `{dir_b.name}` ({rb} rep{'s' * (rb > 1)})", "",
           f"Document: `{A[0]['source'].get('file', '')}`", "",
           f"- A: {meta_line(A)}", f"- B: {meta_line(B)}", ""]
    if ra == 1 or rb == 1:
        who = "A and B are single runs" if ra == rb == 1 else f"{'A' if ra == 1 else 'B'} is a single run"
        out += [f"Note: {who}, so the spread is unknown.", ""]
    out += ["Mean (min–max) over repetitions. A change is real only if the means differ by more "
            "than the spread (max − min) of either run.", "",
            f"| metric | A: {dir_a.name} | B: {dir_b.name} | Δ mean | verdict |", "|---|---|---|---|---|"]
    for name in ma[0]:
        a = summarize([m[name] for m in ma])
        b = summarize([m[name] for m in mb])
        d = b[0] - a[0]
        out.append(f"| {name} | {fmt(*a, ra)} | {fmt(*b, rb)} | {d:+.2f} | {verdict(name, a, b, ra, rb)} |")

    # Per entry: repetitions that passed L0.5.
    ids = list(dict.fromkeys([r["id"] for d in A + B for r in d["results"]]))
    def passed(reps, i):
        vals = [l05(next((r for r in d["results"] if r["id"] == i), {})) for d in reps]
        present = [v for v in vals if v is not None]
        return sum(v == "pass" for v in present), len(present)

    rows = []
    for i in ids:
        pa, na = passed(A, i)
        pb, nb = passed(B, i)
        ra_ = pa / na if na else None
        rb_ = pb / nb if nb else None
        if ra_ is None or rb_ is None:
            change = "only in A" if rb_ is None else "only in B"
        elif rb_ > ra_:
            change = "up"
        elif rb_ < ra_:
            change = "down"
        else:
            continue
        rows.append((change, i, f"{pa}/{na}" if na else "—", f"{pb}/{nb}" if nb else "—"))
    order = {"down": 0, "up": 1, "only in A": 2, "only in B": 3}
    rows.sort(key=lambda r: order[r[0]])
    out += ["", f"## Entries whose L0.5 pass rate changed ({len(rows)})", "",
            "| change | entry | A passed | B passed |", "|---|---|---|---|"]
    out += [f"| {c} | `{i}` | {a} | {b} |" for c, i, a, b in rows]
    same = len(ids) - len(rows)
    out += ["", f"{same} other entries have the same L0.5 pass rate in A and B."]
    return "\n".join(out) + "\n"


# ---------------------------------------------------------------------------
# L1 (arch) runs
# ---------------------------------------------------------------------------

def is_arch_run(run: Path) -> bool:
    return (run / "arch" / "summary.json").exists() or any(run.glob("rep*/arch/summary.json"))


def load_arch_reps(run: Path) -> list:
    """[{group: arch.json}] per repetition."""
    dirs = [run / "arch"] if (run / "arch").exists() else sorted(
        (p for p in run.glob("rep*/arch")), key=lambda p: int("".join(c for c in p.parent.name if c.isdigit()) or 0))
    return [{p.parent.name: json.loads(p.read_text(encoding="utf-8")) for p in d.glob("*/arch.json")} for d in dirs]


def _stage(entry: dict) -> list:
    """Failed stages of one operation's attempts (generate_verified log)."""
    return [x["stage"] for x in entry.get("log", []) if x.get("stage") not in ("ok", "returned")]


def arch_metrics(groups: dict) -> dict:
    ops = [op for g in groups.values() for op in g.get("operations", {}).values()]
    contracts = [i for g in groups.values() for c in (g.get("contracts") or {}).values()
                 for i in (c.get("ops") or {}).values()]
    proved = {k: v for g in groups.values() for k, v in ((g["group"] + "/" + k, v) for k, v in
                                                         (g.get("proved") or {}).items())}
    tr = [v for k, v in proved.items() if "/trace_" in k]
    po1 = [v for k, v in proved.items() if "/po1:" in k]
    po2 = [v for k, v in proved.items() if k.endswith("/po2")]
    sat = [i["satisfiable"] for i in contracts if i.get("satisfiable") is not None]
    vac = [i["vacuous"] for i in contracts if i.get("vacuous") is not None]
    stages = {}
    for op in ops:
        for st in _stage(op):
            stages[st] = stages.get(st, 0) + 1
    pct = lambda xs: round(100 * sum(xs) / len(xs), 1) if xs else 0.0  # noqa: E731
    m = {
        "groups": len(groups),
        "groups accepted": sum(g.get("verdict") == "accepted" for g in groups.values()),
        "Arch.lean compiles": sum(bool(g.get("arch_compiles")) for g in groups.values()),
        "components": sum(len(g.get("order") or []) for g in groups.values()),
        "operations": len(ops),
        "contracts satisfiable %": pct(sat),
        "contracts non-vacuous %": pct([not v for v in vac]),
        "placeholders (no contract)": sum(len(g.get("placeholders") or []) for g in groups.values()),
        "trace proved %": pct(tr),
        "PO1 proved %": pct(po1),
        "PO1 pairs": len(po1),
        "PO2 proved": sum(po2),
        "mean attempts per operation": round(sum(o.get("attempts", 0) for o in ops) / len(ops), 2) if ops else 0,
        "tool calls": sum(g.get("n_tool_calls", 0) for g in groups.values()),
        "minutes": round(sum(g.get("seconds", 0) for g in groups.values()) / 60, 1),
    }
    for st in ("syntax", "names", "types", "proof", "check", "other", "truncated", "weakened"):
        m[f"failed attempts: {st}"] = stages.get(st, 0)
    return m


ARCH_LOWER_BETTER = {"placeholders (no contract)", "mean attempts per operation", "tool calls", "minutes"} | {
    f"failed attempts: {st}" for st in ("syntax", "names", "types", "proof", "check", "other", "truncated", "weakened")}
LOWER_BETTER |= ARCH_LOWER_BETTER


def arch_errors(reps: list, n: int = 3) -> list:
    """Most common first error lines of failed obligations, with one example each."""
    count, example = {}, {}
    for groups in reps:
        for g in groups.values():
            for k, o in (g.get("obligations") or {}).items():
                for e in (o.get("errors") or [])[:1]:
                    key = re.sub(r"`[^`]*`|\d+", "_", e.splitlines()[0])[:90]
                    count[key] = count.get(key, 0) + 1
                    example.setdefault(key, f"{g['group']} {k}: {e.splitlines()[0][:160]}")
    return [(c, k, example[k]) for k, c in sorted(count.items(), key=lambda x: -x[1])[:n]]


def arch_report(dir_a: Path, dir_b: Path) -> str:
    A, B = load_arch_reps(dir_a), load_arch_reps(dir_b)
    ra, rb = len(A), len(B)
    ma, mb = [arch_metrics(r) for r in A], [arch_metrics(r) for r in B]
    meta = lambda reps: next((g.get("meta") for r in reps for g in r.values() if g.get("meta")), {})  # noqa: E731
    out = [f"# L1: `{dir_a.name}` ({ra} reps) vs `{dir_b.name}` ({rb} reps)", ""]
    for tag, reps in (("A", A), ("B", B)):
        m = meta(reps)
        out.append(f"- {tag}: graph mode `{m.get('graph_mode')}`, arch mode `{m.get('arch_mode')}`, model "
                   f"`{m.get('model_id')}`, prompt `{m.get('prompt_hash')}`, graph `{m.get('graph_sha')}`, "
                   f"commit `{m.get('git_commit')}`; modes used "
                   f"{sorted({g.get('mode_used') for r in reps for g in r.values()})}")
    out += ["", "Mean (min–max) over repetitions; a difference is real only beyond the spread.", "",
            f"| metric | A | B | Δ mean | verdict |", "|---|---|---|---|---|"]
    for name in ma[0] if ma else []:
        a = summarize([m[name] for m in ma])
        b = summarize([m[name] for m in mb]) if mb else (0, 0, 0)
        v = verdict(name, a, b, ra, rb)
        out.append(f"| {name} | {fmt(*a, ra)} | {fmt(*b, rb)} | {b[0] - a[0]:+.2f} | {v} |")
    for tag, reps in (("A", A), ("B", B)):
        out += ["", f"## Most common obligation errors in {tag}", ""]
        out += [f"- {c}× `{k}` — e.g. {ex}" for c, k, ex in arch_errors(reps)] or ["- none"]
    return "\n".join(out) + "\n"


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("a", type=Path, help="run folder (before)")
    ap.add_argument("b", type=Path, help="run folder (after)")
    ap.add_argument("-o", "--out", type=Path, help="write the report here (default: stdout)")
    args = ap.parse_args(argv)
    text = arch_report(args.a, args.b) if is_arch_run(args.a) else report(args.a, args.b)
    if args.out:
        args.out.write_text(text, encoding="utf-8")
        print(args.out)
    else:
        sys.stdout.write(text)
    return 0


if __name__ == "__main__":
    sys.exit(main())
