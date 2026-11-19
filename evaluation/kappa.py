"""Cohen's κ between the two human raters of the P8 fidelity sample.

    python evaluation/kappa.py [docs/analysis/p8_fidelity.csv] [--a rater1 --b rater2]

Labels (rubric: docs/analysis/p8_fidelity.md): faithful | adds | omits | wrong; also accepted as
F / A / O / W (any case). A row counts only when both raters filled it in; blank rows are listed
as "not yet rated". Prints κ over the four labels, κ for the binary split faithful vs not, the
observed agreement and the confusion matrix. No model is involved: the rater columns are for
people only.
"""
import argparse
import csv
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LABELS = ["faithful", "adds", "omits", "wrong"]
ALIASES = {"f": "faithful", "a": "adds", "o": "omits", "w": "wrong", "faithful": "faithful",
           "adds": "adds", "adds condition": "adds", "omits": "omits", "omits condition": "omits",
           "wrong": "wrong"}


def norm(v: str):
    v = (v or "").strip().lower()
    if not v:
        return None
    if v not in ALIASES:
        raise ValueError(f"unknown label {v!r} (use one of {', '.join(LABELS)})")
    return ALIASES[v]


def cohen_kappa(a, b) -> float:
    """κ = (p_o − p_e) / (1 − p_e) for two equal-length label lists."""
    n = len(a)
    if n == 0:
        return float("nan")
    po = sum(x == y for x, y in zip(a, b)) / n
    ca, cb = Counter(a), Counter(b)
    pe = sum(ca[k] * cb[k] for k in set(ca) | set(cb)) / (n * n)
    return 1.0 if pe == 1 else (po - pe) / (1 - pe)


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description="Cohen's kappa for the P8 fidelity ratings")
    ap.add_argument("csv", nargs="?", default=str(ROOT / "docs" / "analysis" / "p8_fidelity.csv"))
    ap.add_argument("--a", default="rater1")
    ap.add_argument("--b", default="rater2")
    args = ap.parse_args(argv)
    rows = list(csv.DictReader(open(args.csv, encoding="utf-8")))
    pairs, blank = [], []
    for r in rows:
        x, y = norm(r.get(args.a)), norm(r.get(args.b))
        if x is None or y is None:
            blank.append(r.get("id"))
        else:
            pairs.append((x, y))
    print(f"{len(rows)} rows; rated by both: {len(pairs)}; not yet rated: {len(blank)}")
    if not pairs:
        print("not yet rated: fill in the rater columns (see the rubric in docs/analysis/p8_fidelity.md)")
        return 0
    a, b = [p[0] for p in pairs], [p[1] for p in pairs]
    po = sum(x == y for x, y in pairs) / len(pairs)
    print(f"observed agreement {po:.2f}")
    print(f"Cohen's κ (4 labels): {cohen_kappa(a, b):.3f}")
    fa, fb = [x == "faithful" for x in a], [y == "faithful" for y in b]
    print(f"Cohen's κ (faithful vs not): {cohen_kappa(fa, fb):.3f}")
    for name, col in ((args.a, a), (args.b, b)):
        c = Counter(col)
        print(f"{name}: " + ", ".join(f"{k} {c[k]}" for k in LABELS))
    print("confusion (rows " + args.a + ", columns " + args.b + "):")
    print("          " + " ".join(f"{k:>9}" for k in LABELS))
    for x in LABELS:
        print(f"{x:>9} " + " ".join(f"{sum(1 for p in pairs if p == (x, y)):>9}" for y in LABELS))
    return 0


if __name__ == "__main__":
    sys.exit(main())
