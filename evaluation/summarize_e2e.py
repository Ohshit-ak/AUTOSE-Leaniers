#!/usr/bin/env python3
"""Summarize chain L1/L2 runs: results, why things failed, and the spread over repetitions.

    python evaluation/summarize_e2e.py <run_dir> [<run_dir> ...] [-o report.md]

A run folder has l1l2.json (plus shard files l1l2.<a>-<b>.json; the first record per id wins),
or repetitions rep1/, rep2/, … each with those files (`main.py --until chain --repeat N`).
With repetitions every number is `mean (min–max)`; a difference between two runs is only
real if it is larger than that spread.

What is counted:
    L1 by mode     chain (two components), single (not split: a data constraint, or a `post`
                   with no intermediate result), single-fallback (the split failed, `Spec`
                   kept whole)
                   single-not-decomposable (v11: every split was an identity, so the spec is
                   verified as one component; not an L1 failure)
    end to end     L1 + every L2 + the whole file with `system_ok` accepted by Lean
    v11            copy-ok (weak, but the requirement only passes data through), L2
                   components the harness skeleton implemented without the model, result
                   fields written by the harness vs the model, loops stopped early.
                   Headline: "end to end, non-trivial spec" (and "…, model wrote code")
    weak specs     (chain-v4 runs) specs that an implementation made only of copied input
                   fields and constants satisfies (`spec_check.trivial`). Code verified
                   against such a spec can be a stub, so "end to end, non-trivial spec" is
                   the number to read as "verified code that had to compute something"
    strength       for chain architectures: the chain_checks score (of 6 from chain-v4:
                   the sixth point is "the first result depends on the input"; of 5 before)
    repairs        chain architectures in which the harness removed an unguaranteed part of
                   the second `pre`
    failure classes (harness/chain_failures.py) for L1 and for each L2 component
    1-of-2         specs where exactly one of two components was implemented: which one
                   failed, its class, and whether the contract was implementable at all
Runs made before chain-v3 have no `mode`/`error_class`: they are classified here from the
stored error text. Accepted architectures are re-judged with the current routing rule and
static check (identity / copy-of-Spec components); that re-judgement runs no Lean, so it
does not find constant first results.
"""
import argparse
import collections
import json
import statistics
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "harness"))
import chain_checks as C  # noqa: E402
from chain_failures import classify, root_cause  # noqa: E402


def load_rep(folder: Path) -> list:
    seen, out = set(), []
    for f in sorted(folder.glob("l1l2*.json")):
        for e in json.loads(f.read_text(encoding="utf-8")):
            if e["id"] not in seen:
                seen.add(e["id"])
                out.append(e)
    return out


def load_run(run: Path) -> list:
    """[(rep name, records)]"""
    if list(run.glob("l1l2*.json")):
        return [(run.name, load_rep(run))]
    reps = sorted((p for p in run.glob("rep*") if list(p.glob("l1l2*.json"))),
                  key=lambda p: int("".join(c for c in p.name if c.isdigit()) or 0))
    if not reps:
        sys.exit(f"error: no l1l2*.json in {run} or {run}/rep*/")
    return [(p.name, load_rep(p)) for p in reps]


def _cls(x: dict):
    return x.get("error_class") or classify(x.get("error"), x.get("stages"))


def _spec_of(e: dict, specs: dict):
    return (specs.get(e["id"]) or {}).get("lean_predicate") or ""


def metrics(d: list, specs: dict) -> dict:
    n = len(d)
    l1 = [e.get("l1") or {} for e in d]
    mode = lambda x: x.get("mode", "chain")  # noqa: E731
    ok = [x for x in l1 if x.get("success")]
    l2 = [x for e in d for x in e.get("l2", [])]
    full = [e for e in d if e.get("full_check") is True]
    chain_tried = [x for x in l1 if mode(x) == "chain" or mode(x) == "single-fallback"]
    m = {
        "specs": n,
        "L1 accepted": len(ok),
        "L1 chain (two components)": sum(mode(x) == "chain" for x in ok),
        "L1 single (not split)": sum(mode(x) == "single" for x in ok),
        "L1 single-fallback": sum(mode(x) == "single-fallback" for x in ok),
        "L1 not decomposable (identity split → single)": sum(mode(x) == "single-not-decomposable" for x in ok),
        "L2 components implemented": len([x for x in l2 if x["success"]]),
        "L2 components total": len(l2),
        "end to end": len(full),
        "end to end, chain": sum(mode(e["l1"]) == "chain" for e in full),
        "end to end, single": sum(mode(e["l1"]) != "chain" for e in full),
        "L1 attempts per split spec": (statistics.mean(x.get("attempts", 0) for x in chain_tried)
                                       if chain_tried else 0.0),
        "minutes": sum(e.get("seconds", 0) for e in d) / 60,
    }
    if any("spec_check" in e for e in d):
        weak = lambda e: (e.get("spec_check") or {}).get("trivial") is True  # noqa: E731
        copy_ok = lambda e: weak(e) and (e.get("spec_check") or {}).get("copy_ok") is True  # noqa: E731
        m["weak specs (satisfied by copies and constants)"] = sum(weak(e) for e in d)
        m["end to end, non-trivial spec"] = sum(not weak(e) for e in full)
        if any("copy_ok" in (e.get("spec_check") or {}) for e in d):     # v11
            m["weak specs that only pass data through (copy-ok)"] = sum(copy_ok(e) for e in d)
            m["end to end, copy-ok spec"] = sum(copy_ok(e) for e in full)
    if any("harness_only" in x for x in l2):                              # v11 skeleton
        done = [x for x in l2 if x["success"]]
        m["L2 implemented by the harness skeleton alone"] = sum(bool(x.get("harness_only")) for x in done)
        m["L2 implemented with the model"] = sum(not x.get("harness_only") for x in done)
        m["L2 result fields written by the harness"] = sum(len((x.get("fields") or {}).get("harness", [])) for x in done)
        m["L2 result fields written by the model"] = sum(len((x.get("fields") or {}).get("model", [])) for x in done)
        full_model = [e for e in full if not all(x.get("harness_only") for x in e.get("l2", []))]
        m["end to end, non-trivial spec, model wrote code"] = sum(not weak(e) for e in full_model) \
            if any("spec_check" in e for e in d) else len(full_model)
        m["repair loops stopped early (L1 + L2)"] = sum(bool(x.get("stopped")) for x in l1 + l2)
    m["L1 chain with a repaired second `pre`"] = sum(bool(x.get("repairs")) for x in ok if mode(x) == "chain")
    chains = [x for x in ok if mode(x) == "chain" and x.get("strength")]
    if chains:
        of = max(x["strength"].get("of", 5) for x in chains)
        m[f"strength of chain architectures (of {of})"] = statistics.mean(x["strength"]["score"] for x in chains)
    for kind in sorted({e["kind"] for e in d}):
        m[f"end to end, {kind}"] = sum(e["kind"] == kind for e in full)
        m[f"specs, {kind}"] = sum(e["kind"] == kind for e in d)
    return m


def failures(d: list) -> dict:
    l1c, l2c, one_of_two = collections.Counter(), collections.Counter(), []
    for e in d:
        l1 = e.get("l1") or {}
        if "crash" in e and not l1:
            l1c["crash"] += 1
        elif not l1.get("success"):
            l1c[_cls(l1) or "unknown"] += 1
        elif l1.get("mode") == "single-fallback":
            l1c[f"{(l1.get('failed_split') or {}).get('error_class') or 'unknown'} (fell back to single)"] += 1
        l2 = e.get("l2", [])
        for x in l2:
            if not x["success"]:
                l2c[_cls(x) or "unknown"] += 1
        if len(l2) == 2 and sum(x["success"] for x in l2) == 1:
            k = 0 if not l2[0]["success"] else 1
            one_of_two.append({"id": e["id"], "failed": ("first", "second")[k], "contract": l2[k]["contract"],
                               "class": _cls(l2[k]) or "unknown",
                               "cause": e.get("l2_root_cause") or root_cause(e) or ""})
    return {"l1": l1c, "l2": l2c, "one_of_two": one_of_two}


def rejudge(d: list, specs: dict) -> collections.Counter:
    """Accepted two-component architectures under the current routing rule and static check."""
    out = collections.Counter()
    for e in d:
        l1 = e.get("l1") or {}
        if not l1.get("success") or l1.get("mode", "chain") != "chain":
            continue
        spec = _spec_of(e, specs)
        if not spec:
            out["(no spec text: not judged)"] += 1
            continue
        why = C.single_step(spec, e.get("kind"))
        if why:
            out["single-step spec (not split now)"] += 1
            continue
        problems = C.static_check(C.strip_theorems(l1.get("code") or ""), spec)["problems"]
        out["real decomposition" if not problems else (classify("static: " + "; ".join(problems)) or "other")] += 1
    return out


def spread(values: list) -> str:
    if len(values) == 1:
        v = values[0]
        return f"{v:.2f}" if isinstance(v, float) else str(v)
    mean = statistics.mean(values)
    fmt = (lambda v: f"{v:.2f}") if any(isinstance(v, float) for v in values) else (lambda v: f"{v:g}")
    return f"{mean:.2f} ({fmt(min(values))}–{fmt(max(values))})"


def report(run: Path) -> str:
    reps = load_run(run)
    specs = {}
    for folder in [run, *sorted(run.glob("rep*"))]:
        if (folder / "specs.json").exists():
            specs = {r["id"]: r for r in json.loads((folder / "specs.json").read_text(encoding="utf-8"))["results"]}
            break
    meta_path = next((p for p in [run / "chain_meta.json", *run.glob("rep*/chain_meta.json")] if p.exists()), None)
    if not specs and meta_path:
        root = Path(__file__).resolve().parent.parent
        l0 = root / json.loads(meta_path.read_text(encoding="utf-8")).get("l0_run", "")
        if (l0 / "specs.json").exists():
            specs = {r["id"]: r for r in json.loads((l0 / "specs.json").read_text(encoding="utf-8"))["results"]}
    ms = [metrics(d, specs) for _, d in reps]
    lines = [f"## {run}", "",
             f"{len(reps)} repetition(s): {', '.join(name for name, _ in reps)}"
             + ("" if len(reps) > 1 else " — a single run, so there is no spread and no difference to "
                                         "another run can be called real"), "",
             "| metric | " + ("mean (min–max)" if len(reps) > 1 else "value") + " |", "|---|---|"]
    for key in ms[0]:
        lines.append(f"| {key} | {spread([m.get(key, 0) for m in ms])} |")
    fs = [failures(d) for _, d in reps]
    for title, key in (("L1 failures by class", "l1"), ("L2 component failures by class", "l2")):
        classes = sorted({c for f in fs for c in f[key]}, key=lambda c: -sum(f[key][c] for f in fs))
        lines += ["", f"### {title}", ""]
        if not classes:
            lines.append("none")
        else:
            lines += ["| class | " + ("mean (min–max)" if len(reps) > 1 else "count") + " |", "|---|---|"]
            lines += [f"| {c} | {spread([f[key][c] for f in fs])} |" for c in classes]
    lines += ["", "### Specs with exactly one of two components implemented", ""]
    rows = [(name, o) for (name, _), f in zip(reps, fs) for o in f["one_of_two"]]
    if not rows:
        lines.append("none")
    else:
        lines += ["| rep | spec | failed component | class | structural cause |", "|---|---|---|---|---|"]
        lines += [f"| {name} | {o['id']} | {o['failed']} (`{o['contract']}`) | {o['class']} | {o['cause'] or '—'} |"
                  for name, o in rows]
    judged = [rejudge(d, specs) for _, d in reps]
    if any(judged):
        lines += ["", "### Accepted two-component architectures under the current routing and static check", ""]
        keys = sorted({k for j in judged for k in j}, key=lambda k: -sum(j[k] for j in judged))
        lines += ["| verdict | " + ("mean (min–max)" if len(reps) > 1 else "count") + " |", "|---|---|"]
        lines += [f"| {k} | {spread([j[k] for j in judged])} |" for k in keys]
    never = collections.Counter(e["id"] for _, d in reps for e in d if e.get("full_check") is not True)
    always_fail = sorted(i for i, c in never.items() if c == len(reps))
    lines += ["", f"Not end to end in {'every repetition' if len(reps) > 1 else 'this run'} "
                  f"({len(always_fail)}): " + (", ".join(always_fail) or "none")]
    return "\n".join(lines) + "\n"


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("runs", nargs="+", type=Path)
    ap.add_argument("-o", "--out", type=Path, help="also write the report to this file")
    a = ap.parse_args(argv)
    text = "\n".join(report(r) for r in a.runs)
    print(text)
    if a.out:
        a.out.write_text(text, encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(main())
