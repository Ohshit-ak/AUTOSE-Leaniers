"""Property-based tests of the harness's text functions (no Lean, no model).

Each test states a law that must hold for every input the generator can produce:
round trips, idempotence, invariants of the result, and agreement with a small reference
implementation written here (an oracle). Generators are in tests/strategies.py.

A test marked `xfail(strict=True)` documents a real defect that Hypothesis found; the reason
gives the smallest counterexample. When the defect is fixed the test starts to fail as XPASS:
remove the mark then.
"""
import re

import pytest
from hypothesis import assume, example, given
from hypothesis import strategies as st

import arch_lean as A
import chain_checks as C
import code_lean as CL
import po
import req_parser as P
import skeleton as SK
import validate as V
from agents import repair as R
from agents.base import split_example, strip_redeclared, weakened
from agents.fixups import KEYWORD_FIELDS, apply_fixups
from chain_failures import CLASSES, classify
from llm import extract_lean, is_truncated

from . import strategies as S

text = st.text(max_size=200)
lean_ish = st.text(alphabet="abio.=<>≤∧↔→()[]{} \n01,:λ·/-\"'#_", max_size=120)


# ---------------------------------------------------------------------------
# req_parser: text helpers and quantity extraction
# ---------------------------------------------------------------------------

@given(text)
def test_clean_is_idempotent_and_collapses_whitespace(s):
    c = P.clean(s)
    assert P.clean(c) == c
    assert c == c.strip() and "  " not in c and "\n" not in c and "\t" not in c


@given(text)
def test_slug_is_a_fixed_point_of_lowercase_dashed_names(s):
    g = P.slug(s)
    assert re.fullmatch(r"(?:[a-z0-9]+(?:-[a-z0-9]+)*)?", g)
    assert P.slug(g) == g


@given(text)
def test_arch_slug_and_camel_give_lean_safe_names(s):
    g, c = A.slug(s), A.camel(s)
    assert re.fullmatch(r"[a-z0-9]+(?:_[a-z0-9]+)*", g) and A.slug(g) == g
    assert re.fullmatch(r"[A-Za-z][A-Za-z0-9]*", c) and A.camel(c) == c


_UNITS = sorted(P.MICROS)
_CMPS = sorted(P.CMP_SYMBOL)


@given(st.integers(0, 10**6), st.sampled_from([u for u in _UNITS if u not in ("s", "sec", "min")]),
       st.one_of(st.none(), st.sampled_from(_CMPS)))
def test_time_quantity_is_extracted_exactly(n, unit, cmp):
    sentence = f"The system shall respond {'in ' if not cmp else cmp + ' '}{n} {unit} of the request."
    qs = P.quantities(sentence)
    assert len(qs) == 1
    q = qs[0]
    assert (q["kind"], q["value"], q["unit"]) == ("time", n, unit)
    assert q["micros"] == n * P.MICROS[unit] and isinstance(q["micros"], int)
    assert q["comparator"] == (P.CMP_SYMBOL[cmp] if cmp else "<=")


@given(st.integers(1, 10**4), st.sampled_from(["second", "minute", "hour"]))
def test_equal_durations_in_different_units_give_the_same_bound(n, unit):
    """Metamorphic: `n minutes` and `60·n seconds` are the same latency bound."""
    factor = P.MICROS[unit] // P.MICROS["ms"]
    a = P.quantities(f"within {n} {unit}s")[0]
    b = P.quantities(f"within {n * factor} ms")[0]
    assert a["micros"] == b["micros"] and a["comparator"] == b["comparator"] == "<="


@given(st.lists(st.tuples(st.integers(1, 9999), st.sampled_from(["ms", "seconds", "users", "orders", "%"])),
                min_size=0, max_size=5))
def test_quantities_come_back_in_text_order_and_nothing_is_invented(parts):
    sentence = "The system shall cope with " + " and ".join(f"{n} {u}" for n, u in parts) + "."
    qs = P.quantities(sentence)
    assert [q["value"] for q in qs] == [n for n, _ in parts]
    kinds = {"ms": "time", "seconds": "time", "users": "count", "orders": "count", "%": "percent"}
    assert [q["kind"] for q in qs] == [kinds[u] for _, u in parts]
    assert all(q["comparator"] in {"<", "<=", ">", ">=", "="} for q in qs)


@given(text)
def test_quantities_and_runtime_checks_are_total_and_well_formed(s):
    qs = P.quantities(s)
    for q in qs:
        assert q["kind"] in {"time", "throughput", "count", "percent"}
        assert q["comparator"] in {"<", "<=", ">", ">=", "="}
        assert isinstance(q["value"], (int, float)) and q["value"] >= 0
    for c in P.runtime_checks(s, qs):
        assert c["lean_field"] == P.RUNTIME_FIELD[c["metric"]]
        assert set(c) == {"metric", "operation", "comparator", "bound", "unit", "lean_field"}


@given(st.integers(1, 99), st.integers(1, 99), st.sampled_from(["alphanumeric", "alphabetic", "numeric", ""]))
def test_data_constraints_reads_lengths_and_charset(a, b, charset):
    lo, hi = min(a, b), max(a, b)
    c = P.data_constraints(f"{charset} string, minimum {lo} to maximum {hi} characters, unique")
    assert (c["min_length"], c["max_length"], c["unique"]) == (lo, hi, True)
    assert c.get("charset") == (charset or None)
    assert "exact_length" not in c
    assert P.data_constraints(f"{a}-digit numeric code")["exact_length"] == a


@given(st.lists(st.sampled_from(S.SENTENCES), min_size=1, max_size=6))
def test_sentences_splits_a_paragraph_back_into_its_sentences(sents):
    sents = [s for s in sents if s != "None"]
    assume(sents)
    assert P.sentences(" ".join(sents)) == sents


# ---------------------------------------------------------------------------
# chain_checks: brackets, conjuncts, alpha-equality, contract round trip
# ---------------------------------------------------------------------------

@given(lean_ish)
def test_mask_keeps_positions_and_only_blanks_inside_brackets(t):
    m = C._mask(t)
    assert len(m) == len(t)
    assert all(a == b or a == " " for a, b in zip(m, t))


@given(st.lists(S.atom(), min_size=1, max_size=4))
def test_unparen_strips_every_redundant_outer_bracket(atoms):
    body = " ∧ ".join(atoms)
    core = C._unparen(body)
    assert C._unparen(core) == core
    assert C._unparen(f"(({body}))") == core
    assert C._unparen(f"  ( {body} )  ") == core


@given(st.lists(S.atom(), min_size=1, max_size=6))
def test_conjuncts_is_a_homomorphism_over_top_level_and(atoms):
    """conjuncts(a ∧ b) = conjuncts(a) ++ conjuncts(b); a part with no `∧` of its own is one conjunct."""
    # A quantifier, `→` or `↔` outside brackets takes everything to its right, so only
    # bracketed or plain atoms are joined.
    atoms = [a for a in atoms if a.startswith("(") or not re.search(r"[∀∃↔→¬]", a)]
    assume(atoms)
    parts = C.conjuncts(" ∧ ".join(atoms))
    assert parts == [c for a in atoms for c in C.conjuncts(a)]
    for a in atoms:
        if "∧" not in a:
            assert C.conjuncts(a) == [C._unparen(a)]
    assert all(C.conjuncts(c) == [c] for c in parts)                # the result is fully split


@given(st.lists(S.atom(), min_size=1, max_size=5), st.lists(S.atom(), min_size=1, max_size=3))
def test_an_iff_or_implication_at_top_level_is_one_condition(lhs, rhs):
    for op in ("↔", "→"):
        body = f"{' ∧ '.join(f'({a})' for a in lhs)} {op} {' ∧ '.join(f'({a})' for a in rhs)}"
        assert C.conjuncts(body) == [body]


@given(st.sampled_from(["", "True", " True ", "(True)"]))
def test_true_has_no_conjuncts(body):
    assert C.conjuncts(body) == []


@given(st.lists(S.atom("i"), min_size=1, max_size=4), S.fresh_vars(2), st.integers(0, 3))
def test_canon_ignores_variable_names_spaces_and_outer_brackets(atoms, names, pad):
    a, b = names
    body = " ∧ ".join(atoms)
    ta, tb = S._rename(body, "i", a), S._rename(body, "i", b)
    spaced = re.sub(r" ", " " * (pad + 1), f"( {tb} )")
    assert C.canon(ta, [a]) == C.canon(spaced, [b])


@st.composite
def contracts(draw, name: str = "CheckContract", dom: str = "Input", cod: str = "Output"):
    i, o, p = draw(S.fresh_vars(3))
    pre = draw(st.lists(S.atom(p), max_size=3))
    post = draw(st.lists(st.one_of(S.atom(o), S.atom(i)), min_size=1, max_size=4))
    return C.Contract(name, dom, cod, p, " ∧ ".join(pre) or "True", i, o, " ∧ ".join(post))


@given(contracts())
def test_contract_text_round_trips_through_parse_contracts(c):
    assert C.parse_contracts(C.contract_text(c)) == [c]


@given(contracts("AContract", "Input", "Mid"), contracts("BContract", "Mid", "Output"), contracts("BContract", "Mid", "Output"))
def test_replace_contract_rewrites_one_definition_and_keeps_the_other(a, b, b2):
    code = "structure Mid where\n  n : Nat\n  deriving DecidableEq, Repr\n\n" \
           + C.contract_text(a) + "\n\n" + C.contract_text(b) + "\n"
    out = C.replace_contract(code, b2)
    assert C.parse_contracts(out) == [a, b2]
    assert V.field_types(out) == V.field_types(code)
    assert C.parse_contracts(C.replace_contract(out, b)) == [a, b]


@given(contracts("AContract"), st.lists(st.sampled_from(["-- a note", "-- pre := fun i => True", "--"]), max_size=3))
def test_comments_never_change_what_is_parsed(c, notes):
    code = C.contract_text(c)
    noisy = "\n".join(ln + ("  " + notes[k % len(notes)] if notes else "") for k, ln in enumerate(code.split("\n")))
    assert C.parse_contracts(noisy) == [c]
    assert C.strip_comments(C.strip_comments(noisy)) == C.strip_comments(noisy)
    assert "--" not in C.strip_comments(noisy)


@given(contracts("AContract"), st.sampled_from(["theorem po1 : True := by\n  trivial", "example : 1 = 1 := by\n  decide",
                                                "lemma h : 2 = 2 :=\n  rfl"]))
def test_strip_theorems_removes_proofs_and_keeps_definitions(c, thm):
    code = C.contract_text(c) + "\n\n" + thm + "\n"
    out = C.strip_theorems(code)
    assert not re.search(r"^(theorem|lemma|example)\b", out, re.MULTILINE)
    assert C.parse_contracts(out) == [c]
    assert C.strip_theorems(out) == out


@given(S.spec_models())
def test_intermediate_results_and_single_step_agree(m):
    code = m.code()
    inter = C.intermediate_results(code)
    conj = C.conjuncts(C.spec_contract(code).post)
    assert all(c in conj and len(set(fs)) >= 2 for c, fs in inter)
    why = C.single_step(code)
    # One condition per output field over the input only: there is never an intermediate result.
    assert inter == [] and why is not None
    assert C.single_step(code, "data_constraint") == "data constraint (one validity rule)"
    assert ("single condition" in why) == (len(conj) <= 1)


# ---------------------------------------------------------------------------
# validate: record literals, structure fields, data cases, contradictions
# ---------------------------------------------------------------------------

_plain_str = st.text(alphabet="abc XYZ019,;:{}[]()=", max_size=10).map(lambda s: '"' + s + '"')
lean_value = st.one_of(st.integers(0, 10**6).map(str), st.sampled_from(["true", "false", "[]", "none"]),
                       _plain_str, st.lists(st.integers(0, 99), max_size=4).map(lambda xs: "[" + ", ".join(map(str, xs)) + "]"),
                       st.tuples(st.integers(0, 9), _plain_str).map(lambda t: f"{{ id := {t[0]}, tag := {t[1]} }}"),
                       st.integers(0, 9).map(lambda n: f"(some {n})"))
records = st.dictionaries(S.field_name, lean_value, min_size=1, max_size=5)


@given(records)
def test_literal_fields_inverts_literal(fields):
    assert V.literal_fields(V._literal(fields)) == fields


@given(records, st.integers(1, 4))
def test_one_line_only_touches_whitespace_outside_strings(fields, width):
    lit = V._literal(fields)
    spread = "{\n  " + (",\n" + " " * width).join(f"{k}  :=\t{v}" for k, v in fields.items()) + "\n}"
    one = V.one_line(spread)
    assert "\n" not in one and V.one_line(one) == one
    assert one == lit                                # string contents (with their spaces) survive


@pytest.mark.xfail(strict=True, reason='FINDING: literal_fields toggles "in string" on an escaped quote, so '
                                       '`{ name := "a\\",b", qty := 1 }` is split inside the string (one_line and '
                                       '_balanced do handle the escape)')
@given(st.text(alphabet='ab ,"\\', min_size=0, max_size=6), st.integers(0, 9))
@example('a",b', 1)
def test_literal_fields_reads_strings_that_contain_escaped_quotes(s, n):
    fields = {"name": V._lean_str(s), "qty": str(n)}
    assert V.literal_fields(V._literal(fields)) == fields


@given(S.spec_models())
def test_the_three_structure_parsers_agree(m):
    """validate.field_types, repair.structure_fields and req_graph.structures read the same
    text for three callers; on comment-free code they must give the same fields."""
    import req_graph as G
    code = m.code()
    types = V.field_types(code)
    assert types == {"Input": m.inputs, "Output": m.outputs}
    assert G.structures(code) == types
    assert R.structure_fields(code) == {k: list(v) for k, v in types.items()}


@pytest.mark.xfail(strict=True, reason="FINDING: validate.field_types keeps a trailing `-- comment` in the type "
                                       "(`Nat  -- in cents`), so the type is no longer recognised as `Nat` by the "
                                       "mutant / witness / skeleton code; req_graph.structures strips it")
@given(S.spec_models(), st.sampled_from(["-- in cents", "-- level requested by the operator"]))
def test_a_comment_after_a_field_is_not_part_of_its_type(m, note):
    """Differential: req_graph.structures drops a trailing comment, validate.field_types must too
    (the model does write `configLevel : Nat -- …`; 7 of 576 accepted v11 specs)."""
    code = re.sub(r"^(  \w+ : \w+)$", rf"\1  {note}", m.code(), count=1, flags=re.MULTILINE)
    assert V.field_types(code) == {"Input": m.inputs, "Output": m.outputs}


def _valid_for(value: str, c: dict) -> bool:
    """Reference checker for the parser's data constraints."""
    if "format" in c:
        fmt = c["format"]
        return len(value) == len(fmt) and all(v.isdigit() if f.isalpha() else v == f for v, f in zip(value, fmt))
    if "exact_length" in c and len(value) != c["exact_length"]:
        return False
    if len(value) < c.get("min_length", 0) or len(value) > c.get("max_length", 10**9):
        return False
    ok = {"numeric": str.isdigit, "alphabetic": str.isalpha, "alphanumeric": str.isalnum}.get(c.get("charset"))
    return ok is None or value == "" or all(ok(ch) for ch in value)


data_constraint_dicts = st.one_of(
    st.builds(lambda lo, d, cs: {"min_length": lo, "max_length": lo + d, **cs}, st.integers(1, 20), st.integers(0, 20),
              st.sampled_from([{}, {"charset": "numeric"}, {"charset": "alphabetic"}, {"charset": "alphanumeric"}])),
    st.builds(lambda n, cs: {"exact_length": n, **cs}, st.integers(1, 20),
              st.sampled_from([{}, {"charset": "numeric"}, {"charset": "alphanumeric"}])),
    st.builds(lambda n, cs: {"max_length": n, **cs}, st.integers(1, 30), st.sampled_from([{}, {"charset": "alphabetic"}])),
    st.sampled_from([{"charset": "numeric"}, {"charset": "alphabetic"}, {"format": "MM/YY"}, {"format": "MM/DD/YYYY"},
                     {"format": "YYYY"}, {}]),
)


@given(data_constraint_dicts)
def test_data_cases_are_labelled_correctly(c):
    """Every generated test value is valid exactly when `data_cases` says it should be."""
    cases = V.data_cases(c)
    for value, should_be_valid, why in cases:
        assert _valid_for(value, c) == should_be_valid, (value, why)
    if cases:
        assert cases[0][1] is True and any(not ok for _, ok, _ in cases)


@given(st.sampled_from(["Nat", "Bool", "String", "List Nat", "List String", "Option Nat"]), st.data())
def test_mutants_differ_from_the_value_they_mutate(typ, data):
    value = data.draw({"Nat": st.integers(0, 10**9).map(str), "Bool": st.sampled_from(["true", "false"]),
                       "String": _plain_str, "List Nat": st.sampled_from(["[]", "[1, 2]"]),
                       "List String": st.sampled_from(["[]", '["a"]']),
                       "Option Nat": st.sampled_from(["none", "(some 3)"])}[typ])
    ms = V._mutants(value, typ)
    assert any(m != value for m in ms) or (typ == "Option Nat" and value == "none")


_TERMS = st.sampled_from(["i.count", "o.total", "a.failedAttempts", "n"])


@given(_TERMS, _TERMS, st.integers(1, 9))
def test_self_equation_is_flagged_only_when_both_sides_are_the_same_term(t, u, k):
    spec = lambda eq: f"def Spec : Contract Input Output where\n  pre  := fun i => True\n  post := fun i o => {eq}\n"  # noqa: E731
    for eq in (f"{t} + {k} = {u}", f"{u} = {t} + {k}"):
        assert bool(V.check_contradictions(spec(eq))) == (t == u), eq
    assert not V.check_contradictions(spec(f"{t} + {k} = {t} + {k}"))


@pytest.mark.xfail(strict=True, reason="FINDING: `o.total = o.total + 1 - 1` (true for every value) is reported as "
                                       "'can never be true'; the second _SELF_EQ pattern has no look-ahead for a following operator")
@given(_TERMS, st.integers(1, 9), st.integers(0, 9))
def test_contradiction_check_is_sound_against_arithmetic(t, a, b):
    """Oracle: `t = t + a - b` on `Nat` (truncated subtraction) is satisfiable iff a ≤ b for some t."""
    eq = f"{t} = {t} + {a} - {b}"
    satisfiable = any(n == max(n + a - b, 0) for n in range(0, 30))
    flagged = bool(V.check_contradictions(f"def Spec : Contract I O where\n  post := fun i o => {eq}\n"))
    assert not (flagged and satisfiable), eq


@given(S.spec_models(), st.sampled_from(["i", "o"]))
def test_trivial_nat_bounds_finds_exactly_the_nat_fields(m, side):
    fields = m.inputs if side == "i" else m.outputs
    f = next(iter(fields))
    code = m.structures() + f"\n\ndef Spec : Contract Input Output where\n  pre := fun i => True\n" \
                            f"  post := fun i o => {side}.{f} ≥ 0 ∧ 0 ≤ {side}.{f}\n"
    assert V.trivial_nat_bounds(code) == ([f"{side}.{f}"] if fields[f] == "Nat" else [])


# ---------------------------------------------------------------------------
# skeleton: derived implementations
# ---------------------------------------------------------------------------

@given(S.spec_models(), S.fresh_vars(2))
def test_skeleton_derives_every_field_that_post_fixes(m, names):
    i, o = names
    code = m.code(i, o)
    spec = C.spec_contract(code)
    sk = SK.build(spec, V.field_types(code))
    assert list(sk.values) == list(m.outputs)                       # declaration order, every field
    assert sk.complete and not sk.hints
    assert {f: " ".join(v.split()) for f, v in sk.values.items()} == m.value
    assert set(sk.how.values()) == {"derived"} and sk.derived == list(m.outputs)
    # The rendered function is a record literal the harness can read back: all fields are its own.
    assert SK.provenance(SK.render(sk), sk) == {"harness": list(m.outputs), "model": []}
    assert SK._impl_record(SK.render(sk), sk.impl) == sk.values


@given(S.spec_models(min_out=2), st.data())
def test_skeleton_leaves_a_hole_exactly_where_post_does_not_fix_a_field(m, data):
    """Replace one field's condition by a bound: that field (only) becomes a hole with a hint."""
    f = data.draw(st.sampled_from([g for g, t in m.outputs.items()]))
    assume(m.outputs[f] == "Nat")
    m.post[f] = f"o.{f} ≥ i.{next(g for g, t in m.inputs.items() if t == 'Nat')}"
    code = m.code()
    sk = SK.build(C.spec_contract(code), V.field_types(code))
    assert not sk.complete and sk.values[f] == SK.FILL and sk.how[f] == "hole"
    assert all(SK.FILL not in v for g, v in sk.values.items() if g != f)
    assert any(f"`{f}`" in h for h in sk.hints)
    assert SK.prompt_text(sk).count(SK.FILL) >= 1
    prov = SK.provenance(SK.render(sk).replace(SK.FILL, "0"), sk)
    assert f in prov["model"] and set(prov["harness"]) | set(prov["model"]) == set(m.outputs)


@given(S.spec_models())
def test_skeleton_of_a_spec_that_ignores_its_output_is_empty(m):
    code = m.structures() + "\n\ndef Spec : Contract Input Output where\n  pre := fun i => True\n  post := fun i _ => True\n"
    sk = SK.build(C.spec_contract(code), V.field_types(code))
    assert sk.values == {} and sk.complete and SK.prompt_text(sk) == ""


# ---------------------------------------------------------------------------
# fixups
# ---------------------------------------------------------------------------

_SNIPPETS = ["λ x, x + 1", "xs.take 2.all f", "(· .1)", "{ a := 1, a := 1, b := 2 }", "#eval 1 + 1", "x := 1 // note",
             "structure T where\n  end : Nat\n  s : String\n", "def f (t : T) : Bool := t.s.all Char.isDigit",
             "structure U where\n  n : Nat\n  deriving Repr\n", "{ x // x > 0 }", "t.end + 1", "theorem a : True := trivial"]


@given(st.lists(st.sampled_from(_SNIPPETS), max_size=6))
def test_fixups_report_a_note_exactly_when_they_change_the_code(parts):
    code = "\n".join(parts)
    fixed, notes = apply_fixups(code)
    assert bool(notes) == (fixed != code)
    assert not re.search(r"^\s*#(eval|check)\b", fixed, re.MULTILINE)
    assert "λ" not in fixed or "λ x," not in fixed


@given(st.lists(st.sampled_from(_SNIPPETS), max_size=6))
def test_fixups_are_idempotent(parts):
    fixed, _ = apply_fixups("\n".join(parts))
    assert apply_fixups(fixed) == (fixed, [])


@pytest.mark.xfail(strict=True, reason="FINDING: `{ a := 1, a := 1, a := 1 }` needs two passes: one `re.sub` removes "
                                       "only every other repeat, so apply_fixups is not idempotent on a field written 3+ times")
@given(st.integers(2, 6))
def test_a_field_repeated_n_times_is_reduced_in_one_pass(n):
    fixed, _ = apply_fixups("{ " + ", ".join(["a := 1"] * n) + ", b := 2 }")
    assert fixed == "{ a := 1, b := 2 }"


@given(S.spec_models())
def test_fixups_leave_well_formed_specs_alone(m):
    assert apply_fixups(m.code()) == (m.code(), [])


def _with_keyword_field(m, kw):
    return (m.structures().replace("structure Output where\n", f"structure Output where\n  {kw} : Nat\n")
            + f"\n\ndef Spec : Contract Input Output where\n  pre := fun i => True\n"
              f"  post := fun i o => o.{kw} = 1\n\nexample : Spec.post x {{ {kw} := 1 }} := by decide\n")


@pytest.mark.xfail(strict=True, reason="FINDING: a field named `deriving` (it is in KEYWORD_FIELDS) is renamed to "
                                       "`deriving_`, and _always_derive then takes that field line for the `deriving` "
                                       "clause and rewrites it to `deriving _ : Nat, DecidableEq, Repr`")
@given(S.spec_models())
def test_a_field_named_deriving_is_renamed_like_the_other_keywords(m):
    fixed, _ = apply_fixups(_with_keyword_field(m, "deriving"))
    assert "deriving_" in V.field_types(fixed)["Output"] and "deriving _" not in fixed


@given(S.spec_models(), st.sampled_from([k for k in KEYWORD_FIELDS if k != "deriving"]))
def test_keyword_fields_are_renamed_everywhere(m, kw):
    fixed, notes = apply_fixups(_with_keyword_field(m, kw))
    assert f"renamed keyword field `{kw}` to `{kw}_`" in notes
    assert f"o.{kw}_ = 1" in fixed and f"{{ {kw}_ := 1 }}" in fixed
    assert kw + "_" in V.field_types(fixed)["Output"] and kw not in V.field_types(fixed)["Output"]


@given(S.spec_models(), st.sampled_from(["", "  deriving Repr", "  deriving DecidableEq", "deriving Repr"]))
def test_every_structure_ends_up_deriving_decidable_eq_and_repr(m, deriving):
    code = m.code().replace("  deriving DecidableEq, Repr", deriving)
    fixed, _ = apply_fixups(code)
    lines = re.findall(r"^\s*deriving (.+)$", fixed, re.MULTILINE)
    assert len(lines) == 2 and all({"DecidableEq", "Repr"} <= set(re.split(r",\s*", ln)) for ln in lines)
    assert V.field_types(fixed) == {"Input": m.inputs, "Output": m.outputs}


# ---------------------------------------------------------------------------
# repair: edit distance, suggestions, Lean output
# ---------------------------------------------------------------------------

word = st.text(alphabet="abcdeABCDE_", max_size=8)


@given(word, word, word)
def test_edit_distance_is_a_metric_up_to_case(a, b, c):
    d = R.edit_distance
    assert d(a, a.swapcase()) == 0
    assert d(a, b) == d(b, a)
    assert (d(a, b) == 0) == (a.lower() == b.lower())
    assert d(a, c) <= d(a, b) + d(b, c)
    assert abs(len(a) - len(b)) <= d(a, b) <= max(len(a), len(b))


@given(word, st.lists(word, max_size=10), st.integers(1, 5))
def test_closest_returns_plausible_candidates_nearest_first(name, cands, n):
    out = R.closest(name, cands, n)
    assert len(out) <= n and len(set(out)) == len(out) and set(out) <= set(cands)
    limit = max(2, len(name) // 2)
    dist = lambda c: 1 if (name.lower() in c.lower() or c.lower() in name.lower()) and R.edit_distance(name, c) > 1 \
        else R.edit_distance(name, c)  # noqa: E731
    assert all(dist(c) <= limit for c in out)
    assert [dist(c) for c in out] == sorted(dist(c) for c in out)
    rest = [c for c in set(cands) if c not in out and dist(c) <= limit]
    assert len(out) == n or not rest                               # nothing plausible is left out


@given(S.lean_errors(), st.booleans())
def test_parse_errors_round_trips_lean_output(errors, noise):
    assert R.parse_errors(S.render_lean_output(errors, noise)) == errors


@given(S.lean_errors(min_size=1), st.integers(1, 500), st.integers(0, 50))
def test_error_signature_does_not_depend_on_positions(errors, dl, dc):
    """Metamorphic: the same errors reported further down the file are 'the same error again'."""
    moved = [{**e, "line": e["line"] + dl, "col": e["col"] + dc} for e in errors]
    assert R.error_signature(S.render_lean_output(errors)) == R.error_signature(S.render_lean_output(moved))


@given(S.lean_errors())
def test_earliest_stage_is_the_minimum_stage(errors):
    out = S.render_lean_output(errors)
    stages = [R.error_stage(e["msg"]) for e in errors]
    assert all(s in R.STAGES for s in stages)
    assert R.earliest_stage(out) == (min(stages, key=R.STAGES.index) if stages else None)


@given(S.lean_errors(min_size=1), S.spec_models())
def test_format_feedback_is_bounded_and_shows_only_the_earliest_layer(errors, m):
    code = m.code()
    fb = R.format_feedback(code, S.render_lean_output(errors))
    stage = R.earliest_stage(S.render_lean_output(errors))
    assert fb.startswith(f"Lean errors — {R.STAGE_LABEL[stage]}:")
    shown = re.findall(r"^- (line \d+|locked context):", fb, re.MULTILINE)
    same_stage = [e for e in errors if R.error_stage(e["msg"]) == stage]
    assert len(shown) == min(len(same_stage), R.MAX_ERRORS)
    n_lines = len(code.splitlines())
    for where in shown:                                             # a quoted line number is a line of the code
        assert where == "locked context" or 1 <= int(where.split()[1]) <= n_lines
    assert ("more errors" in fb) == (len(same_stage) > R.MAX_ERRORS)


@given(st.text(max_size=3000))
def test_trim_bounds_a_message(msg):
    t = R._trim(msg)
    assert len(t.splitlines()) <= R.MAX_MSG_LINES and len(t) <= R.MAX_MSG_CHARS + 2
    assert t == msg or len(msg) > len(t) - 2


@given(st.one_of(st.none(), text, S.lean_errors().map(S.render_lean_output)),
       st.sampled_from(["", "L1: ", "L2: ", "static: ", "L0.5: ", "truncated: "]))
def test_classify_is_total_and_names_a_known_class(error, prefix):
    error = None if error is None else prefix + error
    cls = classify(error)
    assert (cls is None) == (not error)
    assert cls is None or cls in CLASSES


@given(st.sampled_from(S._L1_ERRORS + S._L2_ERRORS[:2]), st.sampled_from(["L1: ", "L2: ", "static: ", "L0.5: "]))
def test_classify_of_a_harness_message_ignores_which_stage_reported_it(error, prefix):
    body = error.split(": ", 1)[1]
    assert classify(prefix + body) == classify(error) != "unknown"


# ---------------------------------------------------------------------------
# llm: code extraction and truncation
# ---------------------------------------------------------------------------

_prose = st.sampled_from(["", "Here is the spec:\n", "Sure! The corrected version follows.\n\n", "<think>\nlet me see\n</think>\n"])
_tag = st.sampled_from(["lean", "lean4", "Lean", ""])


@given(S.spec_models(), _prose, _prose, _tag)
def test_extract_lean_returns_the_fenced_code_whatever_surrounds_it(m, before, after, tag):
    code = m.code()
    assert extract_lean(f"{before}```{tag}\n{code}\n```\n{after}") == code
    assert extract_lean(code) == code                               # already bare code
    assert extract_lean(extract_lean(f"{before}```{tag}\n{code}\n```")) == code


@given(S.spec_models(), S.spec_models(), _tag)
def test_extract_lean_keeps_the_last_block_that_defines_spec(m1, m2, tag):
    draft, final = m1.code(), m2.code()
    reply = f"Draft:\n```{tag}\n{draft}\n```\nCorrected:\n```{tag}\n{final}\n```\nUsage:\n```{tag}\n#check Spec\n```"
    assert extract_lean(reply) == final


@given(S.spec_models(), _prose, _tag)
def test_extract_lean_recovers_a_reply_whose_fence_never_closes(m, before, tag):
    assert extract_lean(f"{before}```{tag}\n{m.code()}") == m.code()


@given(text, st.sampled_from([None, "stop", "length", "max_tokens", "FinishReason.MAX_TOKENS", "STOP"]))
def test_is_truncated_follows_the_finish_reason_then_the_fences(reply, reason):
    cut = is_truncated(reply, reason)
    if reason is None:
        assert cut == (reply.count("```") % 2 == 1)
    else:
        assert cut == (reason in ("length", "max_tokens", "FinishReason.MAX_TOKENS"))


# ---------------------------------------------------------------------------
# po / arch_lean / code_lean: harness-written statements
# ---------------------------------------------------------------------------

_tactics = st.lists(st.sampled_from(["intro x h", "simp_all", "omega", "exact h", "decide"]), min_size=1, max_size=4)


@given(_tactics, st.sampled_from(["", "by\n  ", ":= by\n  ", ":=  "]))
def test_theorem_always_yields_one_tactic_block(tactics, lead):
    stmt = "theorem po1 : Contract.Compatible A B"
    proof = lead + "\n  ".join(tactics)
    out = po.theorem(stmt, proof)
    assert out.startswith(stmt + " := by") and out.count(":=") == 1
    assert [ln.strip() for ln in out.split("\n")[1:] if ln.strip()] == tactics or lead.strip() == ":= by" or "by" in lead
    assert out == A.theorem(stmt, proof) or lead.strip() == ":="      # the two helpers agree on tactic proofs


@given(S.spec_models(), st.sampled_from(po.FORBIDDEN + ("axiom",)))
def test_forbidden_words_are_found_as_whole_words_only(m, w):
    code = m.code()
    assert po.forbidden_words(code) == []
    inject = f"axiom cheat : False" if w == "axiom" else f"theorem t : False := by {w}"
    assert po.forbidden_words(code + "\n" + inject) == [w]
    assert po.forbidden_words(code + f"\ndef not{w}x : Nat := 1\ndef {w}_free : Nat := 2") == []


@given(st.text(alphabet="abAB1 _./-#", min_size=1, max_size=10), st.text(alphabet="abAB1 _./-#", min_size=1, max_size=10))
def test_po_statements_name_the_right_definitions(a, b):
    a, b = A.camel(a) + "Contract", A.camel(b) + "Contract"
    assert po.po1_statement(a, b) == f"theorem po1 : Contract.Compatible {a} {b}"
    assert po.po2_statement(f"{a}.seq {b}") == f"theorem po2 : Contract.Refines ({a}.seq {b}) Spec"
    assert po.po3_statement(a, a + "Impl") == f"theorem {a}Impl_ok : {a}.Satisfies {a}Impl"
    thms = C.po_theorems(a, b)
    assert thms["po1"][0] == po.po1_statement(a, b) and thms["po2"][0] == po.po2_statement(f"{a}.seq {b}")


comp_names = st.lists(st.sampled_from(["Account", "Cart", "Order", "Product", "Payment", "Report"]),
                      min_size=1, max_size=6, unique=True)


@given(comp_names)
def test_chain_expression_is_left_nested_and_matches_the_implementation_order(comps):
    expr = A.chain_expr(comps)
    assert expr.count(".seq ") == len(comps) - 1 and expr.count("(") == expr.count(")") == len(comps) - 1
    assert re.findall(r"(\w+)Contract", expr) == comps               # contracts in chain order
    impl = CL.system_impl_expr(comps)
    assert re.findall(r"(\w+)Impl", impl) == comps[::-1]             # g ∘ f applies f first
    assert impl.count("∘") == len(comps) - 1
    thm = A.system_sound_theorem("G", comps)
    assert re.findall(r"\(h\d+ : (\w+)Contract\.Satisfies f\d+\)", thm) == (comps if len(comps) > 1 else [])
    assert ("Contract.compat_seq" in thm) == ("Contract.seq_sound" in thm) == (len(comps) > 2)
    assert thm.count("(") == thm.count(")") and thm.count("{") == thm.count("}")
    assert CL.system_sound_instantiation("G", comps).endswith(" ".join(f"{c}Impl_ok" for c in comps))


@given(comp_names, st.lists(st.sampled_from(["5.1/R1", "UC-login", "DD-password", "3.2.3/S1", "CI-2"]),
                            min_size=1, max_size=5, unique=True), st.data())
def test_generated_contract_and_proof_cover_every_message_once(comps, ops, data):
    owner = {op: data.draw(st.sampled_from(comps)) for op in ops}
    for c in comps:
        owned = [op for op in ops if owner[op] == c]
        text_ = A.contract_def("G", c, owned, ops)
        assert len(re.findall(r"\| \.req_\w+ i =>", text_.split("post :=")[0])) == len(ops)      # pre: every request
        assert len(re.findall(r"\| \.req_\w+ i =>", text_.split("post :=")[1])) == len(owned)    # post: owned only
        proof = CL.auto_po3_proof("G", c, owned, ops)
        assert sorted(re.findall(r"\| (re[qs]_\w+)", proof)) == sorted(
            f"{k}_{A.slug(op)}" for op in ops for k in ("req", "res"))
    spec = A.system_spec("G", ops)
    assert spec.count("Spec.pre i") == spec.count("Spec.post i o") == len(ops)
    po2 = A.auto_po2_proof("G", comps, owner, ops)
    assert po2.count("exact Exists.intro") == len(ops)
    assert A.msg_type("G", ops).count("| re") == 2 * len(ops)


# ---------------------------------------------------------------------------
# agents/base: example split, locked declarations, weakening
# ---------------------------------------------------------------------------

@given(S.spec_models(), st.booleans())
def test_split_example_separates_definitions_from_the_example(m, has_example):
    ex = "example : Spec.pre x := by\n  unfold Spec; decide"
    code = m.code() + ("\n\n" + ex if has_example else "")
    defs, example_ = split_example(code)
    assert defs == m.code() and example_ == (ex if has_example else "")
    assert V.code_defs_only(defs) == defs


@given(S.spec_models(), st.sets(st.sampled_from(["Input", "Output", "Spec"])))
def test_strip_redeclared_removes_exactly_the_locked_declarations(m, locked):
    context = "\n".join(f"def {n} : Nat := 0" for n in sorted(locked))
    out, removed = strip_redeclared(m.code(), context)
    assert sorted(removed) == sorted(locked)
    left = set(re.findall(r"^(?:structure|def)\s+(\w+)", out, re.MULTILINE))
    assert left == {"Input", "Output", "Spec"} - locked
    assert strip_redeclared(out, context) == (out, [])


@given(S.spec_models())
def test_weakened_detects_a_spec_replaced_by_true(m):
    code = m.code()
    assert weakened(code, code) is None
    gutted = re.sub(r"post := fun i o => .*", "post := fun i o => True", code)
    assert weakened(code, gutted) is not None
    if m.pre:
        assert weakened(code, re.sub(r"pre  := fun i => .*", "pre  := fun i => True", code)) == "`pre` was replaced by `True`"
