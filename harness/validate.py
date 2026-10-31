"""L0.5: check generated specs before they go to L1.

Lean only says a spec compiles. These checks look for specs that compile but are
wrong or say nothing. They are rule-based (no model) and work from the parser's
JSON, so the same spec always gets the same verdict.

    1. housekeeping  one `Spec`, an `example`, no `sorry`/`axiom`/`native_decide`,
                     `Contract` not redefined                              (fail)
    2. vacuity       `post` rejects at least one changed output            (fail)
                     `pre := True` on a use case with preconditions        (fail)
                     `pre := True` on another requirement or use case      (flag)
    3. parser facts  runtime fields and bounds are in the spec             (fail)
                     counted bounds appear in the spec                     (flag)
    4. data tests    for data fields: values built from the parser's length/
                     charset/format rules are accepted or rejected as they
                     should be                                             (flag)

Hard problems (fail) are also fed back into L0's repair loop (`hard_checks`).
Flags are for a person to review. Usage on an existing run:
    python validate.py "../runs/0000 - gamma j/qwen/specs.json"
"""
import json
import re
import sys
from pathlib import Path
from typing import List, Optional, Tuple

from agents.base import split_example
from agents.repair import parse_errors, structure_fields
from lean_runner import HEADER, check_lean

_STRUCT_BLOCK = re.compile(r"^structure\s+(\w+)[^\n]*\bwhere\s*\n((?:[ \t]+.*\n?)*)", re.MULTILINE)
_FIELD_TYPE = re.compile(r"^[ \t]+(\w+)\s*:\s*(.+?)\s*$", re.MULTILINE)
_TRIVIAL_PRE = re.compile(r"\bpre\s*:=\s*fun\s+[\w_]+\s*=>\s*[Tt]rue\s*$", re.MULTILINE)
BIG = 1_000_000_000


# ---------------------------------------------------------------------------
# Small Lean-source helpers
# ---------------------------------------------------------------------------

def field_types(code: str) -> dict:
    """{structure: {field: type}} for structures in `code`."""
    out = {}
    for m in _STRUCT_BLOCK.finditer(code):
        out[m.group(1)] = {f: t for f, t in _FIELD_TYPE.findall(m.group(2))
                           if f != "deriving" and not t.startswith("DecidableEq")}
    return out


def _balanced(text: str, start: int, open_ch: str = "{", close_ch: str = "}") -> Optional[int]:
    """Index just past the group opened at text[start], or None."""
    depth, in_str = 0, False
    for k in range(start, len(text)):
        c = text[k]
        if c == '"' and text[k - 1] != "\\":
            in_str = not in_str
        elif not in_str and c == open_ch:
            depth += 1
        elif not in_str and c == close_ch:
            depth -= 1
            if depth == 0:
                return k + 1
    return None


def example_witness(code: str) -> Optional[Tuple[str, str]]:
    """(input literal, output literal) from `Spec.post { … } { … }` in the example."""
    _, example = split_example(code)
    m = re.search(r"Spec\.post\s*", example)
    if not m:
        return None
    groups, k = [], m.end()
    for _ in range(2):
        while k < len(example) and example[k].isspace():
            k += 1
        if k >= len(example) or example[k] != "{":
            return None
        end = _balanced(example, k)
        if end is None:
            return None
        groups.append(example[k:end])
        k = end
    return groups[0], groups[1]


def literal_fields(lit: str) -> dict:
    """{field: value text} for a record literal `{ a := 1, b := "x" }`."""
    body, out, depth, in_str, cur = lit.strip()[1:-1], {}, 0, False, ""
    parts = []
    for c in body:
        if c == '"':
            in_str = not in_str
        if not in_str and c in "([{":
            depth += 1
        if not in_str and c in ")]}":
            depth -= 1
        if c == "," and depth == 0 and not in_str:
            parts.append(cur)
            cur = ""
        else:
            cur += c
    parts.append(cur)
    for p in parts:
        if ":=" in p:
            k, v = p.split(":=", 1)
            out[k.strip()] = v.strip()
    return out


def _literal(fields: dict) -> str:
    return "{ " + ", ".join(f"{k} := {v}" for k, v in fields.items()) + " }"


def _lean_str(s: str) -> str:
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def _check_examples(code: str, examples: List[str]) -> List[bool]:
    """Check each extra `example` after `code`; True where it passes."""
    text = code + "\n\n" + "\n\n".join(examples)
    result = check_lean(text)
    if result["success"]:
        return [True] * len(examples)
    first = HEADER.count("\n") + code.count("\n") + 3  # line of the first extra example
    starts, line = [], first
    for ex in examples:
        starts.append(line)
        line += ex.count("\n") + 2
    bad = set()
    for e in parse_errors(result["error"]):
        for i in range(len(examples) - 1, -1, -1):
            if e["line"] >= starts[i]:
                bad.add(i)
                break
        else:
            return [False] * len(examples)  # error in the spec itself
    return [i not in bad for i in range(len(examples))]


def _top_level_split(body: str, sep: str) -> List[str]:
    """Split `body` at `sep` outside brackets and strings."""
    parts, depth, in_str, cur, k = [], 0, False, "", 0
    while k < len(body):
        c = body[k]
        if c == '"':
            in_str = not in_str
        if not in_str and c in "([{⟨":
            depth += 1
        if not in_str and c in ")]}⟩":
            depth -= 1
        if not in_str and depth == 0 and body.startswith(sep, k):
            parts.append(cur)
            cur, k = "", k + len(sep)
            continue
        cur += c
        k += 1
    parts.append(cur)
    return [p.strip() for p in parts if p.strip()]


def _clause_body(code: str, name: str) -> Optional[Tuple[List[str], str]]:
    """(binder names, body) of `pre := fun i => body` / `post := fun i o => body`."""
    defs, _ = split_example(code)
    m = re.search(rf"^\s*{name}\s*:=\s*fun\s+([\w\s_]+?)\s*=>(.*?)(?=^\s*(?:pre|post)\s*:=|\Z)",
                  defs, re.MULTILINE | re.DOTALL)
    if not m:
        return None
    return m.group(1).split(), " ".join(m.group(2).split())


def false_conjuncts(code: str) -> List[str]:
    """Parts of `pre`/`post` (split at top-level `∧`) that are false for the example's values.

    Used when `decide` proves the example false, so the model learns which
    condition its values break instead of just "the proposition is false".
    """
    w = example_witness(code)
    if not w:
        return []
    inp, out = w
    checks, labels = [], []
    for name, args in (("pre", [("Input", inp)]), ("post", [("Input", inp), ("Output", out)])):
        cb = _clause_body(code, name)
        if not cb or len(cb[0]) != len(args):
            continue
        binders, body = cb
        if any(len(_top_level_split(body, op)) > 1 for op in ("↔", "→", "∨")):
            parts = [body]  # lower-precedence operator at top level: don't split
        else:
            parts = _top_level_split(body, "∧")
        names = [b if b != "_" else f"x{n}" for n, b in enumerate(binders)]
        quant = " ".join(f"({b} : {t})" for b, (t, _) in zip(names, args))
        eqs = " → ".join(f"{b} = {lit}" for b, (_, lit) in zip(names, args))
        intro = " ".join(names) + " " + " ".join(f"h{n}" for n in range(len(names)))
        substs = "; ".join(f"subst h{n}" for n in range(len(names)))
        for part in parts:
            checks.append(f"example : ∀ {quant}, {eqs} → ({part}) := by\n"
                          f"  intro {intro}; {substs}; decide")
            labels.append(f"{name}: {part}")
    if not checks:
        return []
    return [lab for lab, ok in zip(labels, _check_examples(code_defs_only(code), checks)) if not ok]


def code_defs_only(code: str) -> str:
    return split_example(code)[0]


# ---------------------------------------------------------------------------
# Witness search: the harness picks example values instead of the model
# ---------------------------------------------------------------------------

MAX_CANDIDATES = 400
_CHUNK = 100


def _default(t: str) -> Optional[str]:
    t = t.strip()
    if t == "Nat":
        return "0"
    if t == "Bool":
        return "true"
    if t == "String":
        return '""'
    if t.startswith("List"):
        return "[]"
    if t.startswith("Option"):
        return "none"
    return None


def _pool(t: str, orig: Optional[str], nums: List[int], strs: List[str]) -> List[str]:
    t = t.strip()
    vals = [orig] if orig else []
    if t == "Nat":
        base = [0, 1, 2, 5, 10, 100] + nums + [n + 1 for n in nums] + [n - 1 for n in nums if n > 0]
        vals += [str(n) for n in base]
    elif t == "Bool":
        vals += ["true", "false"]
    elif t == "String":
        vals += ['""', '"a"'] + strs[:6]
        for n in nums:
            if 0 < n <= 64:
                vals += [_lean_str(_sample(cs, n)) for cs in ("alphanumeric", "numeric", "alphabetic")]
    elif t.startswith("List"):
        vals += ["[]"]
    elif t.startswith("Option"):
        inner = _default(t[len("Option"):].strip(" ()"))
        vals += ["none"] + ([f"(some {inner})", "(some 1)"] if inner else [])
    out = []
    for v in vals:
        if v not in out:
            out.append(v)
    return out[:14]


def find_witness(code: str) -> Optional[str]:
    """A checked `example` proving `Spec.pre i ∧ Spec.post i o`, found by search, or None.

    Values come from the spec itself (its numbers, string literals, strings of the
    lengths it mentions) and from the model's own example, so it needs no
    knowledge of the requirement. Candidates are checked by Lean in batches.
    """
    import itertools
    types = field_types(code)
    tin, tout = types.get("Input"), types.get("Output")
    if not tin or not tout:
        return None
    defs, _ = split_example(code)
    w = example_witness(code)
    lin, lout = (literal_fields(w[0]), literal_fields(w[1])) if w else ({}, {})
    nums = sorted({int(n) for n in re.findall(r"(?<![\w.])(\d{1,7})(?![\w.])", defs)})[:8]
    strs = sorted(set(re.findall(r'"[^"\n]*"', defs)))
    pin = {f: _pool(t, lin.get(f) or _default(t), nums, strs) for f, t in tin.items()}
    pout = {f: _pool(t, lout.get(f) or _default(t), nums, strs) for f, t in tout.items()}
    if any(not v for v in list(pin.values()) + list(pout.values())):
        return None

    base_in = {f: v[0] for f, v in pin.items()}
    out_fields = list(pout)
    cands = []
    # 1. the model's input with every combination of output values
    for combo in itertools.islice(itertools.product(*pout.values()), MAX_CANDIDATES // 2):
        cands.append((base_in, dict(zip(out_fields, combo))))
    # 2. one input field changed, with each single-field change of the output
    base_out = {f: v[0] for f, v in pout.items()}
    out_singles = [base_out] + [{**base_out, f: v} for f, vs in pout.items() for v in vs[1:]]
    for f, vs in pin.items():
        for v in vs[1:]:
            for o in out_singles:
                cands.append(({**base_in, f: v}, o))
    cands = cands[:MAX_CANDIDATES]

    for k in range(0, len(cands), _CHUNK):
        chunk = cands[k:k + _CHUNK]
        exs = [f"example : Spec.pre {_literal(i)} ∧ Spec.post {_literal(i)} {_literal(o)} := by\n"
               f"  unfold Spec; decide" for i, o in chunk]
        for ex, ok in zip(exs, _check_examples(defs, exs)):
            if ok:
                return ex
    return None


# ---------------------------------------------------------------------------
# Checks
# ---------------------------------------------------------------------------

def check_housekeeping(code: str) -> List[str]:
    problems = []
    if len(re.findall(r"^def\s+Spec\b", code, re.MULTILINE)) != 1:
        problems.append("there must be exactly one `def Spec`")
    if re.search(r"^structure\s+Contract\b", code, re.MULTILINE):
        problems.append("`Contract` is redefined; it already exists")
    for word in ("sorry", "admit", "native_decide"):
        if re.search(rf"\b{word}\b", code):
            problems.append(f"`{word}` is not allowed")
    if re.search(r"^axiom\b", code, re.MULTILINE):
        problems.append("`axiom` is not allowed")
    if not re.search(r"^example\b", code, re.MULTILINE):
        problems.append("there must be an `example` proving `Spec.pre i ∧ Spec.post i o`")
    return problems


def _mutants(value: str, typ: str) -> List[str]:
    typ = typ.strip()
    if typ == "Bool":
        return ["false" if value == "true" else "true"]
    if typ == "Nat":
        try:
            n = int(value)
        except ValueError:
            return ["0", str(BIG)]
        return [str(n + 1)] + (["0"] if n != 0 else []) + ([str(BIG)] if n != BIG else [])
    if typ == "String":
        return ['""', value[:-1] + '#"' if value.endswith('"') else '"#"']
    if typ.startswith("List"):
        if value.strip() != "[]":
            return ["[]"]
        elem = {"Nat": "7", "String": '"#"', "Bool": "true"}.get(typ[len("List"):].strip(" ()"))
        return [f"[{elem}]"] if elem else []
    if typ.startswith("Option"):
        return ["none"] if value.strip() != "none" else []
    return []


def check_vacuity(code: str) -> Tuple[List[str], List[str]]:
    """(hard problems, flags): `post` must reject some single-field change of the example output."""
    w = example_witness(code)
    out_types = field_types(code).get("Output")
    if not w or not out_types:
        return [], ["could not test whether `post` rejects anything (example not in `Spec.post {…} {…}` form)"]
    inp, out = w
    fields = literal_fields(out)
    mutants = []
    for f, v in fields.items():
        for m in _mutants(v, out_types.get(f, "")):
            mutants.append(_literal({**fields, f: m}))
    if not mutants:
        return [], ["could not test whether `post` rejects anything (no field types to vary)"]
    claim = " ∧ ".join(f"Spec.post {inp} {m}" for m in mutants)
    ok = _check_examples(code, [f"example : ¬ ({claim}) := by\n  unfold Spec; decide"])[0]
    if ok:
        return [], []
    return ["`post` accepted every changed output we tried (each field of the example output "
            "changed in turn), so it does not constrain the output"], []


def check_parser_facts(code: str, entry: dict) -> Tuple[List[str], List[str]]:
    problems, flags = [], []
    out_fields = structure_fields(code).get("Output", [])
    for c in entry.get("runtime_checks") or []:
        if c["lean_field"] not in out_fields:
            problems.append(f"`Output` needs the runtime field `{c['lean_field']}` ({c['unit']})")
        if not re.search(rf"\b{c['bound']}\b", code):
            problems.append(f"the runtime bound `{c['lean_field']} {c['comparator']} {c['bound']}` "
                            "is missing from `post`")
    if not entry.get("runtime_checks"):
        for q in entry.get("quantities") or []:
            if q.get("kind") == "count" and not re.search(rf"\b{q['value']}\b", code):
                flags.append(f"the bound {q['comparator']} {q['value']} {q['unit']} does not appear in the spec")
    if _TRIVIAL_PRE.search(code):
        if entry.get("kind") == "use_case" and entry.get("preconditions"):
            problems.append("the use case has preconditions, but `pre` is `True`; state them in `pre`")
        elif entry.get("kind") in ("requirement", "use_case"):
            flags.append("`pre` is `True`: the spec assumes nothing about the input")
    return problems, flags


def _sample(charset: str, n: int) -> str:
    alphabet = {"numeric": "1", "alphabetic": "a", "alphanumeric": "a1"}.get(charset, "a1")
    return (alphabet * (n // len(alphabet) + 1))[:n]


def data_cases(constraints: dict) -> List[Tuple[str, bool, str]]:
    """[(value, should_be_valid, why)] built from the parser's constraints."""
    c, cases = constraints, []
    charset = c.get("charset")
    if "format" in c:
        fmt = c["format"]
        valid = "".join("1" if ch.isalpha() else ch for ch in fmt)
        cases.append((valid, True, f"matches the format {fmt}"))
        sep = [ch for ch in fmt if not ch.isalnum()]
        if sep:
            cases.append((valid.replace(sep[0], ""), False, f"separator `{sep[0]}` missing"))
        cases.append(("a" + valid[1:], False, "a letter where the format has a digit"))
        return cases
    lo = c.get("exact_length", c.get("min_length", 1))
    hi = c.get("exact_length", c.get("max_length"))
    if hi is None and "min_length" not in c and not charset:
        return []
    n = hi if hi is not None else max(lo, 1)
    valid = _sample(charset, n)
    cases.append((valid, True, f"length {n}" + (f", {charset}" if charset else "")))
    if hi is not None:
        cases.append((_sample(charset, hi + 1), False, f"too long ({hi + 1} > {hi})"))
    if lo and lo > 1 or "exact_length" in c:
        cases.append((_sample(charset, lo - 1), False, f"too short ({lo - 1} < {lo})"))
    bad_char = {"numeric": "a", "alphabetic": "1"}.get(charset, "#")
    if charset and n >= 1:
        cases.append((bad_char + valid[1:], False, f"contains `{bad_char}`, not {charset}"))
    return cases


def check_data_tests(code: str, entry: dict) -> List[str]:
    """Flags for data-field specs that accept or reject the wrong values."""
    if entry.get("kind") != "data_constraint":
        return []
    types = field_types(code)
    inp, out = types.get("Input", {}), types.get("Output", {})
    s_fields = [f for f, t in inp.items() if t == "String"]
    b_fields = [f for f, t in out.items() if t == "Bool"]
    if len(inp) != 1 or len(s_fields) != 1 or len(out) != 1 or len(b_fields) != 1:
        return ["data tests skipped: `Input` is not one `String` field and `Output` one `Bool` field"]
    cases = data_cases(entry.get("constraints", {}))
    if not cases:
        return []
    f, b = s_fields[0], b_fields[0]
    examples = [f"example : Spec.pre {{ {f} := {_lean_str(v)} }} → "
                f"Spec.post {{ {f} := {_lean_str(v)} }} {{ {b} := {'true' if ok else 'false'} }} := by\n"
                f"  unfold Spec; decide" for v, ok, _ in cases]
    flags = []
    for (v, ok, why), passed in zip(cases, _check_examples(code, examples)):
        if not passed:
            flags.append(f"{'rejects a valid' if ok else 'accepts an invalid'} value {_lean_str(v)} ({why})")
    return flags


# ---------------------------------------------------------------------------
# Entry points
# ---------------------------------------------------------------------------

def hard_checks(entry: dict):
    """Validator for the L0 repair loop: problems that must be fixed before L1."""
    def validate(code: str) -> List[str]:
        problems = check_housekeeping(code)
        if problems:
            return problems
        problems += check_parser_facts(code, entry)[0]
        problems += check_vacuity(code)[0]
        return problems
    return validate


def review(code: str, compiled: Optional[bool], entry: dict) -> dict:
    """Full L0.5 verdict for one spec: {status: pass|flag|fail, problems, flags}."""
    if not compiled:
        return {"status": "fail", "problems": ["does not compile"], "flags": []}
    problems = check_housekeeping(code)
    p, flags = check_parser_facts(code, entry)
    problems += p
    if not problems:
        p, f = check_vacuity(code)
        problems += p
        flags += f
        flags += check_data_tests(code, entry)
    status = "fail" if problems else "flag" if flags else "pass"
    return {"status": status, "problems": problems, "flags": flags}


def review_run(specs: dict, entries: dict) -> dict:
    """Add an `l05` verdict to every result and return {status: count}."""
    counts = {"pass": 0, "flag": 0, "fail": 0}
    for r in specs["results"]:
        r["l05"] = review(r["lean_predicate"], r["checked"], entries.get(r["id"], {}))
        counts[r["l05"]["status"]] += 1
    specs["l05_summary"] = counts
    return counts


def write_report(specs: dict, out_dir: Path) -> Path:
    """Markdown report for people + review.json with a default decision per entry."""
    icon = {"pass": "✅", "flag": "⚠️", "fail": "❌"}
    default = {"pass": "accept", "flag": "review", "fail": "redo"}
    s = specs["l05_summary"]
    lines = [f"# L0.5 report — {specs['source'].get('file', '')} ({specs['model']})", "",
             f"Compiles: {specs['summary']['checked']}/{specs['summary']['total']} · "
             f"✅ pass {s['pass']} · ⚠️ flagged {s['flag']} · ❌ fail {s['fail']}", "",
             "| | Entry | Kind | Reasons |", "|---|---|---|---|"]
    decisions = {}
    for r in specs["results"]:
        v = r["l05"]
        reasons = "; ".join(v["problems"] + v["flags"]) or "—"
        lines.append(f"| {icon[v['status']]} | `{r['id']}` | {r['kind']} | {reasons.replace('|', '/')} |")
        decisions[r["id"]] = {"status": v["status"], "decision": default[v["status"]],
                              "reasons": v["problems"] + v["flags"], "note": ""}
    report = out_dir / "l05_report.md"
    report.write_text("\n".join(lines) + "\n", encoding="utf-8")
    review_path = out_dir / "review.json"
    if review_path.exists():  # keep decisions a person already made
        old = json.loads(review_path.read_text(encoding="utf-8"))
        for k, d in old.items():
            if k in decisions and d.get("decision") != default[d.get("status", "fail")]:
                decisions[k]["decision"], decisions[k]["note"] = d["decision"], d.get("note", "")
    review_path.write_text(json.dumps(decisions, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return report


def entries_for(specs: dict) -> dict:
    """Parser entries by id, from the parsed JSON next to the source XML."""
    from config import ROOT
    stem = Path(specs["source"]["file"]).stem
    doc = json.loads((ROOT / "Requirements" / "parsed" / f"{stem}.json").read_text(encoding="utf-8"))
    return {e["id"]: e for e in doc["requirements"] + doc["data_dictionary"] + doc["use_cases"]}


if __name__ == "__main__":
    path = Path(sys.argv[1])
    specs = json.loads(path.read_text(encoding="utf-8"))
    print(review_run(specs, entries_for(specs)))
    path.write_text(json.dumps(specs, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(write_report(specs, path.parent))
