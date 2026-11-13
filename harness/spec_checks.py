"""L0.5 checks on what a spec asks of the code (v11). No model; same spec → same verdict.

The model tends to treat a spec as text to copy, not a rule to satisfy. Whether copying the
input is enough is a property of the *spec*, so these checks run at L0.5, before any code is
written, and their findings go back into the L0 repair loop:

    output-mention     every top-level conjunct of `Spec.post` must constrain the output.
                       `i.count ≤ 3` in `post` is a fact about the input, and so is
                       `∀ t ∈ o.items, t.id ≠ 0` when `post` also fixes `o.items = i.items`:
                       no implementation can establish it unless `pre` gives it (Lean
                       tries to prove it from `pre`; only what it cannot prove is reported)  (fail)
    realizability      for the example input and a few inputs generated from it that
                       satisfy `pre`, some output must satisfy `post`. OFF by default
                       (CF_REALIZABILITY=1): on the v10.1 specs 56 of the 129 chain-v4
                       spec-runs it flagged were verified, i.e. the output search misses too
                       often to be given to the model. The Lean-backed output-mention check
                       above covers the unrealizable specs it can prove.                (record)
    copy-satisfiable   the harness builds implementations made only of copied input fields
                       and constants (`chain_checks.trivial_witness`); if `post` accepts
                       one, the spec is *weak*: verified code for it can be a stub. Fed
                       back once; then the spec is accepted and recorded as weak.    (record)
                       A requirement that genuinely echoes data ("display the user's name")
                       is tagged `copy-ok` from its verb and reported separately.

`spec_strength(code, entry)` is the record stored with each spec (`l05.strength`).
None of this names a field, function or requirement of any particular SRS.
"""
import itertools
import os
import re
from typing import Dict, List, Optional, Tuple

import chain_checks as C
from validate import (_check_examples, _literal, _pool, code_defs_only, example_witness, field_types,
                      literal_fields)

# Verbs of requirements whose job is to pass data through unchanged (show, store, return…).
# A copy implementation is the right answer for these, so a copy witness is not a defect.
COPY_VERBS = ("display", "show", "view", "list", "print", "present", "echo", "retrieve", "store",
              "save", "record", "retain", "keep", "archive", "export", "copy", "forward")
# Verbs that ask for a decision or a computation; when one is present the spec is not copy-ok
# even if a copy verb also appears ("validate and display …").
COMPUTE_VERBS = ("validate", "verify", "check", "calculate", "compute", "determine", "decide",
                 "reject", "accept", "allow", "deny", "prevent", "restrict", "limit", "filter",
                 "sort", "order", "rank", "count", "sum", "total", "add", "subtract", "increase",
                 "decrease", "update", "change", "modify", "remove", "delete", "cancel", "approve",
                 "authenticate", "authorize", "lock", "unlock", "notify", "warn", "alert", "match",
                 "search", "find", "select", "assign", "generate", "convert", "format", "round",
                 "expire", "require", "enforce", "ensure", "terminate", "initiate", "process", "route",
                 "register", "confirm", "compare", "exceed")
# A condition or a bound means the requirement decides something, even with a copy verb.
CONDITION = re.compile(r"\b(if|when|whenever|unless|only|except|until|unique|at (?:most|least)|"
                       r"maximum|minimum|within|no more than|not (?:exceed|more|less)|shall not|must not|"
                       r"cannot|never|before|after)\b|\d", re.IGNORECASE)
REALIZABILITY = os.getenv("CF_REALIZABILITY", "0") == "1"
MAX_REAL_INPUTS = 3      # inputs (besides the example's) for the realizability search
MAX_REAL_OUTPUTS = 120   # output candidates tried per input


def _verbs(text: str, verbs) -> List[str]:
    words = re.findall(r"[a-z]+", (text or "").lower())
    found = []
    for v in verbs:
        stem = v[:-1] if v.endswith("e") else v
        if any(w == v or (w.startswith(stem) and len(w) - len(stem) <= 3) for w in words):
            found.append(v)
    return found


def requirement_text(entry: Optional[dict]) -> str:
    entry = entry or {}
    if entry.get("kind") == "use_case":
        return " ".join([entry.get("name") or "", entry.get("goal") or ""]
                        + list(entry.get("postconditions") or []))
    return entry.get("text") or entry.get("description") or ""


def copy_ok(entry: Optional[dict]) -> bool:
    """True when the requirement's verbs say it passes data through (and nothing asks for a
    decision or a computation), so a copy implementation is what it asks for."""
    if (entry or {}).get("kind") == "data_constraint":
        return False
    text = requirement_text(entry)
    return (bool(_verbs(text, COPY_VERBS)) and not _verbs(text, COMPUTE_VERBS)
            and not CONDITION.search(text))


# ---------------------------------------------------------------------------
# Output-mention
# ---------------------------------------------------------------------------

def unrealizable_conjuncts(code: str, lean: bool = True) -> List[Tuple[str, str, List[str]]]:
    """[(conjunct, what it says about the input, output fields substituted)] for the conjuncts of
    `post` that only constrain the input, and that Lean cannot prove from `pre`:

    - conjuncts that never mention the output (`i.count ≤ 3`), and
    - conjuncts that only constrain the input once the outputs `post` fixes elsewhere
      (`o.f = <input expression>`) are put in: `o.items = i.items ∧ ∀ t ∈ o.items, t.id ≠ 0`
      is `∀ t ∈ i.items, t.id ≠ 0` for every implementation.

    Unless `pre` gives such a condition, no code can establish it. With `lean=False` only the
    textual part runs (no `pre` check)."""
    defs = code_defs_only(code)
    s = C.spec_contract(defs)
    if s is None or s.out_var == "_":
        return []
    o, i = s.out_var, s.in_var
    parts = C.conjuncts(s.post)
    fixed_rx = re.compile(rf"{re.escape(o)}\.([\w']+)\s*=\s*(.+)", re.DOTALL)

    def fixes(c: str):
        p = C._unparen(c)
        if re.search(r"[↔→∨]", C._mask(p)):
            return None
        m = fixed_rx.fullmatch(p)
        if m and not C._mentions(m.group(2), o) and not re.match(r"[=>]", m.group(2)):
            return m.group(1), C._unparen(m.group(2))
        return None

    fixed: Dict[str, str] = {}
    for c in parts:
        fx = fixes(c)
        if fx:
            fixed.setdefault(*fx)
    pre_set = {C.canon(c, [s.pre_var]) for c in C.conjuncts(s.pre)}
    cands = []
    for c in parts:
        if not C._mentions(c, o):
            cands.append((" ".join(c.split()), " ".join(c.split()), []))
            continue
        fx = fixes(c)
        if fx and fx[0] in fixed:
            continue
        sub, used = c, []
        for f, e in sorted(fixed.items(), key=lambda kv: -len(kv[0])):
            rx = rf"(?<![\w.']){re.escape(o)}\.{re.escape(f)}(?![\w'])"
            if re.search(rx, sub):
                sub, used = re.sub(rx, lambda _m: f"({e})", sub), used + [f]
        if used and not C._mentions(sub, o):
            cands.append((" ".join(c.split()), " ".join(sub.split()), used))
    cands = [c for c in cands if C.canon(c[1], [i]) not in pre_set]
    if not cands or not lean or i == "_":
        return cands
    import po
    thms = [f"example : ∀ ({i} : Input), Spec.pre {i} → ({sub}) := by\n"
            f"  intro {i} hpre\n  simp only [Spec] at hpre\n  {C.CLOSERS} | decide" for _, sub, _ in cands]
    return [cand for cand, (ok, _) in zip(cands, po.run_theorems(defs, thms)) if not ok]


def output_mention_problems(code: str, lean: bool = True) -> List[str]:
    s = C.spec_contract(code_defs_only(code))
    if s is None:
        return []
    return format_unrealizable(unrealizable_conjuncts(code, lean), s.out_var)


def format_unrealizable(found: List[Tuple[str, str, List[str]]], o: str = "o") -> List[str]:
    """Repair feedback for `unrealizable_conjuncts`."""
    out = []
    for c, sub, used in found:
        if not used:
            out.append(f"`post` contains `{c}`, which never mentions the output `{o}`: it is a fact about the "
                       f"input that `pre` does not ensure, so no implementation can make it true. If the "
                       f"requirement assumes it, move it to `pre`; otherwise remove it. Every condition of "
                       f"`post` must say something about `{o}`.")
        else:
            fs = ", ".join(f"`{o}.{f}`" for f in used)
            out.append(f"`post` fixes {fs} elsewhere, so `{c}` only says `{sub}` about the input, and `pre` "
                       f"does not ensure that: no implementation can make it true. If the requirement assumes "
                       f"it, add it to `pre`; if the output should differ from the input (e.g. keep only the "
                       f"elements that satisfy it), change the condition that fixes {fs}.")
    return out


# ---------------------------------------------------------------------------
# Realizability
# ---------------------------------------------------------------------------

def _inputs_and_pools(code: str):
    types = field_types(code)
    tin, tout = types.get("Input"), types.get("Output")
    w = example_witness(code)
    if not tin or not tout or not w:
        return None
    defs = code_defs_only(code)
    lin, lout = literal_fields(w[0]), literal_fields(w[1])
    nums = sorted({int(n) for n in re.findall(r"(?<![\w.])(\d{1,7})(?![\w.])", defs)})[:8]
    strs = sorted(set(re.findall(r'"[^"\n]*"', defs)))
    pin = {f: _pool(t, lin.get(f), nums, strs) for f, t in tin.items()}
    return tin, tout, lin, lout, pin, nums, strs


def _output_candidates(inp: dict, tin: dict, tout: dict, lout: dict, nums, strs) -> List[dict]:
    """Outputs for `inp`: each field from the example output, a same-named / same-typed input
    value, and the usual constants."""
    norm = lambda t: " ".join(t.split())  # noqa: E731
    pools = []
    for f, t in tout.items():
        same = [inp[g] for g, tg in tin.items() if norm(tg) == norm(t) and g in inp]
        same.sort(key=lambda v: v != inp.get(f))
        vals = list(dict.fromkeys(same[:2] + _pool(t, lout.get(f), nums, strs)))
        if not vals:
            return []
        pools.append(vals[:8])
    names = list(tout)
    first = [{f: lout[f] for f in names}] if set(lout) == set(names) else []
    rest = [dict(zip(names, combo)) for combo in itertools.islice(itertools.product(*pools), MAX_REAL_OUTPUTS)]
    return first + [o for o in rest if o not in first]


def realizability_misses(code: str) -> List[str]:
    """Input literals that satisfy `pre` but for which no output candidate satisfies `post`.
    Empty when every tested input has an output, or when the spec cannot be tested."""
    got = _inputs_and_pools(code)
    if got is None:
        return []
    tin, tout, lin, lout, pin, nums, strs = got
    defs = code_defs_only(code)
    if set(lin) != set(tin):
        return []
    # Inputs: the example's, then single-field changes; keep those Lean says satisfy `pre`.
    inputs = [lin] + [{**lin, f: v} for f, vs in pin.items() for v in vs[1:3] if v != lin.get(f)]
    inputs = inputs[:12]
    pre_checks = [f"example : Spec.pre {_literal(i)} := by\n  unfold Spec; decide" for i in inputs]
    with_pre = [i for i, ok in zip(inputs, _check_examples(defs, pre_checks)) if ok][:MAX_REAL_INPUTS + 1]
    if not with_pre or with_pre[0] != lin:
        return []   # the example input itself fails `pre` here: the test is not trustworthy
    misses = []
    for k, inp in enumerate(with_pre):
        outs = _output_candidates(inp, tin, tout, lout, nums, strs)
        exs = [f"example : Spec.post {_literal(inp)} {_literal(o)} := by\n  unfold Spec; decide" for o in outs]
        if not exs:
            return []
        hits = _check_examples(defs, exs)
        if k == 0 and not hits[0]:
            return []   # the example's own output is rejected here: the test is not trustworthy
        if not any(hits):
            misses.append(_literal(inp))
    return misses


def realizability_problems(code: str) -> List[str]:
    misses = realizability_misses(code)
    if not misses:
        return []
    return [f"for the input `{m}`, which satisfies `pre`, no output we tried satisfies `post`. Check that "
            "the conditions of `post` can hold together for every input that `pre` allows; a condition that "
            "only some inputs can meet belongs in `pre`." for m in misses[:2]]


# ---------------------------------------------------------------------------
# Copy-satisfiability
# ---------------------------------------------------------------------------

def copy_witness(code: str) -> Optional[str]:
    """A copy-and-constants implementation `post` accepts (the spec is weak), or None."""
    return C.trivial_witness(code_defs_only(code))


def weak_spec_problem(witness: str) -> str:
    return (f"`post` is too weak: the implementation `{witness}` (only copied input fields and fixed "
            "values) satisfies it, so code verified against this spec need not do anything the "
            "requirement asks. Add the conditions that tie each output field to the rule in the "
            "requirement (what it must be computed from, and when it differs from the input).")


def spec_strength(code: str, entry: Optional[dict] = None, realizability: Optional[bool] = None) -> dict:
    """{"output_free": [...], "unrealizable_inputs": [...], "trivial": bool, "witness": str|None,
    "copy_ok": bool, "class": "strong" | "weak" | "copy-ok" | "unrealizable"}."""
    found = unrealizable_conjuncts(code)
    s = C.spec_contract(code_defs_only(code))
    free = [c for c, _, _ in found]
    realizability = REALIZABILITY if realizability is None else realizability
    misses = realizability_misses(code) if realizability and not free else []
    witness = copy_witness(code) if not free else None
    ok = copy_ok(entry)
    cls = ("unrealizable" if free else
           ("copy-ok" if ok else "weak") if witness else "strong")
    return {"output_free": free, "output_problems": format_unrealizable(found, s.out_var if s else "o"),
            "unrealizable_inputs": misses, "trivial": witness is not None,
            "witness": witness, "copy_ok": ok, "class": cls}


def loop_checks(entry: Optional[dict]):
    """Validator part for the L0 repair loop (used by `validate.hard_checks`).

    Output-mention problems are always reported. The weak-spec finding (and the realizability
    miss, when CF_REALIZABILITY=1) is a judgement about strength / an incomplete search, so it is
    reported at most once per entry: if the model cannot fix it, the spec is accepted and
    recorded as weak instead of burning every attempt."""
    told: Dict[str, bool] = {}
    ok = copy_ok(entry)

    def check(code: str) -> List[str]:
        problems = output_mention_problems(code)
        if problems:
            return problems
        if REALIZABILITY and not told.get("real"):
            p = realizability_problems(code)
            if p:
                told["real"] = True
                return p
        if not ok and not told.get("weak"):
            w = copy_witness(code)
            if w:
                told["weak"] = True
                return [weak_spec_problem(w)]
        return []
    return check
