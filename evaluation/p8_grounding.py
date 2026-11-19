"""P8 / P11: are the constants of a spec grounded in its requirement? Deterministic, no model.

A spec is *grounded* when every literal constant in its definitions (the `pre` / `post` of
`Spec`, helper `def`s, structure field defaults; never the satisfiability `example`) comes
from the requirement or is derivable from it:

    numbers   0 and 1 (structural: empty / non-empty, `≥ 1`); a number that appears in the
              requirement text or in the parser entry (quantities, constraints), also written
              with thousands separators or as a word ("twenty", "1,000"); n ± 1 of such a number
              (strict vs non-strict bound); n × / ÷ 10, 60, 100, 1000, 3600, 10^6 (unit change:
              dollars → cents, s → ms); lengths, segment lengths and offsets of a format token
              in the text (`MM/DD/YYYY` gives 10, 2, 4, 3, 6, …); 12 when the text names a month
              (`MM`, "month", "date"), 31 when it names a day (`DD`, "day", "date")
    strings   "" ; a literal whose letters/digits (lower-cased) occur in the requirement's
              letters/digits, i.e. it is quoted from the text
    chars     ' ' ; a character that occurs in the requirement text

Everything else is reported: e.g. the gamma j login spec's `"registeredUsername"` (an invented
account) or a `3` failed-attempts threshold that the SRS never states.

    grounded(spec_code, entry, text=None) -> (bool, [ungrounded constants])

`entry` is the parser entry (Requirements/parsed/<doc>.json); `text` optionally adds the
requirement text stored with the spec. Used by evaluation/strength_score.py (P11 payoff 0
when ungrounded).

CLI: python evaluation/p8_grounding.py [-o docs/analysis/p8_grounding.md]
    over every accepted spec of runs/*/qwen-v11/rep1 (checked and accepted in review.json).
"""
import argparse
import json
import re
import sys
from pathlib import Path
from typing import Iterable, List, Optional, Tuple

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "harness"))

import chain_checks as C  # noqa: E402
from validate import code_defs_only  # noqa: E402

# Keys of a parser entry that hold requirement content. Ids, section numbers and step numbers
# are left out: "5.1/R4" must not ground a 4.
_TEXT_KEYS = {"text", "description", "field", "name", "goal", "preconditions", "postconditions",
              "basic_scenario", "alternative_scenarios", "steps", "quantities", "constraints",
              "value", "unit", "min_length", "max_length", "length", "charset", "format", "default",
              "max_ref", "min", "max", "signals", "comparator"}
_SKIP_KEYS = {"id", "section", "section_path", "step", "flow", "goto", "resolves_to", "kind",
              "category", "verification", "group", "actors", "type", "actor", "has_precondition"}

_WORDS = {"zero": 0, "one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6, "seven": 7,
          "eight": 8, "nine": 9, "ten": 10, "eleven": 11, "twelve": 12, "fifteen": 15, "twenty": 20,
          "thirty": 30, "forty": 40, "fifty": 50, "hundred": 100, "thousand": 1000, "million": 10 ** 6}
_SCALES = (10, 60, 100, 1000, 3600, 10 ** 6)
_FORMAT = re.compile(r"\b[MDYHSmdyhs]{1,4}(?:[/\-:.][MDYHSmdyhs]{1,4})+\b")


def _collect(entry, out_text: List[str], out_nums: List[int], key: Optional[str] = None) -> None:
    if key in _SKIP_KEYS:
        return
    if isinstance(entry, dict):
        for k, v in entry.items():
            _collect(v, out_text, out_nums, k)
    elif isinstance(entry, list):
        for v in entry:
            _collect(v, out_text, out_nums, key)
    elif isinstance(entry, bool):
        return
    elif isinstance(entry, (int, float)):
        if key is None or key in _TEXT_KEYS:
            out_nums.append(int(entry))
    elif isinstance(entry, str):
        if key is None or key in _TEXT_KEYS:
            out_text.append(entry)


def source(entry: Optional[dict], text: Optional[str] = None) -> Tuple[str, set]:
    """(requirement text, numbers stated in it) for a parser entry (+ stored text)."""
    texts, nums = [], []
    _collect(entry or {}, texts, nums)
    if text:
        texts.append(text)
    t = " ".join(texts)
    for m in re.finditer(r"\d[\d,]*(?:\.\d+)?", t):
        s = m.group(0).rstrip(",")
        whole, _, frac = s.partition(".")
        nums.append(int(whole.replace(",", "")))
        if frac:
            nums.append(int(frac))
    low = t.lower()
    for w, v in _WORDS.items():
        if re.search(rf"\b{w}\b", low):
            nums.append(v)
    return t, set(nums)


def derivable_numbers(t: str, nums: Iterable[int]) -> set:
    ok = {0, 1}
    for n in nums:
        ok |= {n, n + 1, max(n - 1, 0)}
        for k in _SCALES:
            ok.add(n * k)
            if n % k == 0:
                ok.add(n // k)
    for m in _FORMAT.finditer(t):
        tok = m.group(0)
        ok.add(len(tok))
        pos = 0
        for seg in re.split(r"([/\-:.])", tok):
            ok |= {len(seg), pos, pos + len(seg)}
            pos += len(seg)
    low = t.lower()
    if re.search(r"\bMM\b", t) or re.search(r"\b(month|date)", low):
        ok.add(12)
    if re.search(r"\bDD\b", t) or re.search(r"\b(day|date)", low):
        ok.add(31)
    return ok


def _mask_strings(code: str) -> str:
    return re.sub(r'"(?:[^"\\\n]|\\.)*"', lambda m: '"' + " " * (len(m.group(0)) - 2) + '"', code)


def constants(spec_code: str) -> Tuple[List[int], List[str], List[str]]:
    """(numbers, string literals, char literals) of the spec's definitions."""
    defs = C.strip_comments(code_defs_only(spec_code))
    defs = re.sub(r"^\s*deriving\b.*$", "", defs, flags=re.MULTILINE)
    strings = re.findall(r'"((?:[^"\\\n]|\\.)*)"', defs)
    chars = re.findall(r"'((?:[^'\\\n]|\\.))'", defs)
    masked = re.sub(r"'(?:[^'\\\n]|\\.)'", "' '", _mask_strings(defs))
    # identifiers with digits (`x1`, `Spec_2`) and name suffixes are not numbers
    nums = [int(n) for n in re.findall(r"(?<![\w.'])(\d+)(?![\w])", masked)]
    return nums, strings, chars


def _alnum(s: str) -> str:
    return re.sub(r"[^0-9a-z]", "", s.lower())


def grounded(spec_code: str, entry: Optional[dict], text: Optional[str] = None) -> Tuple[bool, List[str]]:
    """(True, []) when every constant of the spec is grounded in the requirement, else
    (False, the ungrounded constants as Lean literals, each once)."""
    t, nums = source(entry, text)
    okn = derivable_numbers(t, nums)
    talnum = _alnum(t)
    bad: List[str] = []
    n, s, ch = constants(spec_code)
    for v in n:
        if v not in okn:
            bad.append(str(v))
    for v in s:
        if v == "" or (_alnum(v) and _alnum(v) in talnum):
            continue
        if not _alnum(v) and all(c in t for c in v):
            continue
        bad.append(f'"{v}"')
    for v in ch:
        if v in (" ", "\\n") or v in t or v.lower() in t.lower():
            continue
        bad.append(f"'{v}'")
    bad = list(dict.fromkeys(bad))
    return not bad, bad


# ---------------------------------------------------------------------------
# Stored v11 runs
# ---------------------------------------------------------------------------

def parsed_entries(doc: str) -> dict:
    p = ROOT / "Requirements" / "parsed" / f"{doc}.json"
    if not p.exists():
        return {}
    d = json.loads(p.read_text(encoding="utf-8"))
    return {e["id"]: e for e in d["requirements"] + d["data_dictionary"] + d["use_cases"]}


def accepted(run: Path) -> List[dict]:
    specs = json.loads((run / "specs.json").read_text(encoding="utf-8"))
    rp = run / "review.json"
    review = json.loads(rp.read_text(encoding="utf-8")) if rp.exists() else None
    return [r for r in specs["results"] if r.get("checked") is True
            and (review is None or review.get(r["id"], {}).get("decision") == "accept")]


def v11_runs(run_name: str = "qwen-v11") -> List[Tuple[str, Path]]:
    return [(p.parent.parent.name, p) for p in sorted((ROOT / "runs").glob(f"*/{run_name}/rep1"))
            if (p / "specs.json").exists()]


# ---------------------------------------------------------------------------
# P8 fidelity sample: a deterministic, stratified sample for the human meaning review
# ---------------------------------------------------------------------------

FIDELITY_QUOTA = {"weak": 24, "strong": 33, "copy-ok": 3}   # 60 specs, at least 20 weak
FIDELITY_COLUMNS = ["n", "doc", "id", "kind", "strength_class", "requirement_text", "lean_types",
                    "lean_pre", "lean_post", "auto_hint", "rater1", "rater2"]


def _key(doc: str, sid: str) -> str:
    import hashlib
    return hashlib.sha256(f"{doc}\0{sid}".encode("utf-8")).hexdigest()


def fidelity_sample(run_name: str = "qwen-v11") -> List[dict]:
    """Per strength class, round-robin over the SRS (sorted by name), each SRS's specs in
    sha256(doc, id) order, until the class quota is reached. Same stored data → same sample."""
    pools = {}
    for doc, run in v11_runs(run_name):
        for r in accepted(run):
            cls = ((r.get("l05") or {}).get("strength") or {}).get("class") or "unknown"
            pools.setdefault(cls, {}).setdefault(doc, []).append(r)
    picked = []
    for cls, quota in FIDELITY_QUOTA.items():
        docs = {d: sorted(rs, key=lambda r: _key(d, r["id"])) for d, rs in sorted(pools.get(cls, {}).items())}
        k = 0
        while quota and any(docs.values()):
            for d in list(docs):
                if quota and docs[d]:
                    picked.append((d, cls, docs[d].pop(0)))
                    quota -= 1
            k += 1
    return [{"doc": d, "cls": c, "r": r} for d, c, r in picked]


def _one(text: str) -> str:
    return " ".join((text or "").split())


def write_fidelity_csv(path: Path, run_name: str = "qwen-v11") -> List[dict]:
    import csv
    ents_by_doc = {}
    rows = []
    for n, x in enumerate(fidelity_sample(run_name), 1):
        d, r = x["doc"], x["r"]
        ents = ents_by_doc.setdefault(d, parsed_entries(d))
        code = r["lean_predicate"]
        s = C.spec_contract(code_defs_only(code))
        from validate import field_types
        ft = field_types(code_defs_only(code))
        types = "; ".join(f"{st}: " + ", ".join(f"{f} : {_one(t)}" for f, t in fs.items()) for st, fs in ft.items())
        ok, bad = grounded(code, ents.get(r["id"]), r.get("requirement_text"))
        st = (r.get("l05") or {}).get("strength") or {}
        hints = []
        if not ok:
            hints.append("ungrounded constants: " + ", ".join(bad[:6]))
        if st.get("witness"):
            hints.append("copy/constant implementation satisfies it: " + _one(st["witness"]))
        flags = (r.get("l05") or {}).get("flags") or []
        if flags:
            hints.append("L0.5 flags: " + "; ".join(_one(f)[:120] for f in flags[:2]))
        rows.append({"n": n, "doc": d, "id": r["id"], "kind": r["kind"], "strength_class": x["cls"],
                     "requirement_text": _one(r.get("requirement_text")), "lean_types": types,
                     "lean_pre": _one(s.pre) if s else "", "lean_post": _one(s.post) if s else _one(code),
                     "auto_hint": " | ".join(hints), "rater1": "", "rater2": ""})
    with open(path, "w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=FIDELITY_COLUMNS)
        w.writeheader()
        w.writerows(rows)
    return rows


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--run-name", default="qwen-v11")
    ap.add_argument("--fidelity-csv", help="write the 60-spec P8 fidelity sample (rater columns blank) here and stop")
    ap.add_argument("-o", "--out", help="write the markdown report here (default: print it)")
    args = ap.parse_args(argv)
    if args.fidelity_csv:
        from collections import Counter
        rows = write_fidelity_csv(Path(args.fidelity_csv), args.run_name)
        print(f"{len(rows)} specs -> {args.fidelity_csv}; by class {dict(Counter(r['strength_class'] for r in rows))}; "
              f"{len({r['doc'] for r in rows})} SRS; with an auto hint {sum(bool(r['auto_hint']) for r in rows)}")
        return 0
    rows, examples = [], []
    tot = [0, 0, 0]
    for doc, run in v11_runs(args.run_name):
        ents = parsed_entries(doc)
        specs = accepted(run)
        n_bad, n_const = 0, 0
        for r in specs:
            ok, bad = grounded(r["lean_predicate"], ents.get(r["id"]), r.get("requirement_text"))
            if not ok:
                n_bad += 1
                n_const += len(bad)
                examples.append((doc, r["id"], bad))
        rows.append((doc, len(specs), n_bad, n_const))
        tot = [tot[0] + len(specs), tot[1] + n_bad, tot[2] + n_const]
    lines = ["# P8: grounding of the accepted L0 v11 specs",
             "",
             f"Generated by `evaluation/p8_grounding.py` over `runs/*/{args.run_name}/rep1` (accepted specs:"
             " checked and accepted in review.json). Deterministic, no model. A spec is ungrounded when one",
             "of its constants (numbers, strings, chars in the definitions; not the `example`) does not come",
             "from the requirement text or parser entry; the rules are in the module docstring.",
             "",
             "| SRS | accepted specs | ungrounded specs | ungrounded constants |",
             "|---|---:|---:|---:|"]
    lines += [f"| {d} | {n} | {b} | {c} |" for d, n, b, c in rows]
    lines += [f"| **total** | **{tot[0]}** | **{tot[1]}** ({100 * tot[1] / max(tot[0], 1):.0f} %) | **{tot[2]}** |",
              "", "## Ungrounded specs", "", "| SRS | id | constants not in the requirement |", "|---|---|---|"]
    def cell(bad):
        return ", ".join("`" + b.replace("|", "\\|") + "`" for b in bad[:8]) + (" …" if len(bad) > 8 else "")
    lines += [f"| {d} | `{i}` | {cell(bad)} |" for d, i, bad in examples]
    lines += ["", "Caveats: the rules accept a number that is a unit change or ± 1 of a stated number, so a",
              "grounded spec can still use a stated number in the wrong place; and domain facts the SRS does",
              "not state (a month has at most 12, an e-mail address has an `@`) count as ungrounded unless",
              "the text names them. Read the list, not only the count."]
    text = "\n".join(lines) + "\n"
    if args.out:
        Path(args.out).parent.mkdir(parents=True, exist_ok=True)
        Path(args.out).write_text(text, encoding="utf-8")
    print(text)
    return 0


if __name__ == "__main__":
    sys.exit(main())
