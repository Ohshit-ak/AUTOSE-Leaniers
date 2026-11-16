"""Metamorphic tests (no Lean, no model).

There is no oracle for "is this the right architecture verdict / report / parse": the expected
output of a new input is not known. A metamorphic relation sidesteps that: change the input in
a way whose effect on the output IS known (rename a bound variable, reorder a conjunction,
pad whitespace, shuffle repetitions) and compare the two outputs with each other.

The source inputs are the pipeline's own recorded outputs (tests/corpus.py): every SRS
document, every accepted L0 spec of the latest run and every accepted two-component
architecture, plus generated documents for the parser. A relation is checked on the whole
corpus and the test lists every case that breaks it.

    MR-P*   parser            whitespace, namespace, re-serialisation, appended sections
    MR-S*   L0 specs          alpha-renaming, conjunct order, comments, code fences
    MR-A*   L1 architectures  alpha-renaming, definition order, comments
    MR-F*   repair feedback   locked-context offset, error positions
    MR-E*   evaluation        repetition order, repeated repetition, shards, self-comparison
"""
import json
import random
import re
import xml.etree.ElementTree as ET

import pytest
from hypothesis import given, settings
from hypothesis import strategies as st

import chain_checks as C
import compare_runs as CR
import req_parser as P
import skeleton as SK
import spec_checks as SC
import summarize_e2e as E
import validate as V
from agents import repair as R
from agents.fixups import apply_fixups
from chain_failures import classify
from lean_runner import HEADER
from llm import extract_lean

from . import corpus
from . import strategies as S
from .test_pbt_pipeline import _docs


def _fail_list(bad, what):
    assert not bad, f"{what}: {len(bad)} case(s), e.g. {bad[:3]}"


def _body(doc: dict) -> dict:
    return {k: v for k, v in doc.items() if k != "source"}


# ---------------------------------------------------------------------------
# MR-P: parser
# ---------------------------------------------------------------------------

@given(_docs(), st.integers(0, 10**6))
def test_mr_p1_whitespace_between_words_and_tags_changes_nothing(secs, seed):
    plain = P.parse_bytes(S.render_document(secs), "t.xml")
    padded = P.parse_bytes(S.render_document(secs, pad=random.Random(seed)), "t.xml")
    assert _body(padded) == _body(plain)
    assert padded["source"]["sha256"] != plain["source"]["sha256"] or not any(True for _ in secs)


@given(_docs())
def test_mr_p2_an_xml_namespace_changes_nothing(secs):
    assert _body(P.parse_bytes(S.render_document(secs, xmlns="req_document.xsd"), "t.xml")) == \
        _body(P.parse_bytes(S.render_document(secs), "t.xml"))


@given(_docs(), S.sections("90"), st.sampled_from(["References", "Glossary", "Purpose", "User Interfaces"]))
def test_mr_p3_a_non_normative_section_adds_no_requirement(secs, extra, title):
    extra.title = title
    extra.prose = [p for p in extra.prose if p != "None"]
    for c in extra.walk():
        c.prose = [p for p in c.prose if p != "None"]
    before = P.parse_bytes(S.render_document(secs), "t.xml")
    after = P.parse_bytes(S.render_document(secs + [extra]), "t.xml")
    assert after["requirements"] == before["requirements"]
    assert after["dropped"][:len(before["dropped"])] == before["dropped"]
    assert all(d["reason"].startswith("non-normative section") for d in after["dropped"][len(before["dropped"]):])


@given(_docs(), S.sections("91"))
def test_mr_p4_appending_a_section_never_changes_earlier_entries(secs, extra):
    for c in extra.walk():
        c.prose = [p for p in c.prose if p != "None"]
    before = P.parse_bytes(S.render_document(secs), "t.xml")
    after = P.parse_bytes(S.render_document(secs + [extra]), "t.xml")
    assert after["requirements"][:len(before["requirements"])] == before["requirements"]
    assert after["dropped"][:len(before["dropped"])] == before["dropped"]
    new_ids = [r["id"] for r in after["requirements"][len(before["requirements"]):]]
    assert all(i.startswith("91") for i in new_ids)


@given(_docs())
def test_mr_p5_typographic_quotes_and_no_break_spaces_are_normalised(secs):
    plain = S.render_document(secs).decode("utf-8")
    fancy = plain.replace("The system", "The system").replace(" the ", "  the ")
    assert _body(P.parse_bytes(fancy.encode("utf-8"), "t.xml")) == _body(P.parse_bytes(plain.encode("utf-8"), "t.xml"))


@pytest.mark.parametrize("xml", corpus.srs_documents(), ids=lambda p: p.stem)
def test_mr_p6_reserialising_a_real_srs_gives_the_same_parse(xml):
    """Real documents: write the XML back through ElementTree (comments, declaration, attribute
    quoting and entity spelling change; the content does not) and parse again."""
    data = xml.read_bytes()
    again = ET.tostring(ET.fromstring(data), encoding="utf-8")
    assert again != data
    a, b = P.parse_bytes(data, xml.name), P.parse_bytes(again, xml.name)
    assert _body(a) == _body(b)
    assert a["source"]["sha256"] != b["source"]["sha256"]


# ---------------------------------------------------------------------------
# MR-S: L0 specs (corpus: every checked spec of the latest L0 run, rep1)
# ---------------------------------------------------------------------------

SPECS = corpus.checked_specs()


def _renamed(s: C.Contract, names) -> C.Contract:
    """`s` with its bound variables renamed (`_` binders stay)."""
    p, i, o = names
    ren = lambda t, old, new: t if old == "_" else S._rename(t, old, new)  # noqa: E731
    return C.Contract(s.name, s.dom, s.cod, p if s.pre_var != "_" else "_", ren(s.pre, s.pre_var, p),
                      i if s.in_var != "_" else "_", o if s.out_var != "_" else "_",
                      ren(ren(s.post, s.in_var, i), s.out_var, o))


def _rename_spec(code: str, s: C.Contract, names) -> str:
    """`code` with the bound variables of `Spec` renamed (definitions only)."""
    return C.replace_contract(V.code_defs_only(code), _renamed(s, names))


def _renamable(code: str, s: C.Contract) -> bool:
    """Binders inside the body that reuse a contract variable would be captured by a textual rename."""
    inner = C._bound(s.pre) | C._bound(s.post)
    return not inner & {s.pre_var, s.in_var, s.out_var} and not re.search(r"\b(zp|zi|zo)\b", code)


def test_corpus_is_present():
    assert len(SPECS) > 400 and len(corpus.chain_architectures()) > 20 and len(corpus.srs_documents()) == 18


def test_mr_s1_renaming_the_variables_of_a_spec_changes_no_verdict():
    bad, n = [], 0
    for run, rid, code in SPECS:
        s = C.spec_contract(V.code_defs_only(code))
        if s is None or not _renamable(code, s):
            continue
        n += 1
        renamed = _rename_spec(code, s, ("zp", "zi", "zo"))
        t = C.spec_contract(renamed)
        base = C.replace_contract(V.code_defs_only(code), s)        # same normalisation, original names
        same = (
            C.canon(s.pre, [s.pre_var]) == C.canon(t.pre, [t.pre_var])
            and C.canon(s.post, [s.in_var, s.out_var]) == C.canon(t.post, [t.in_var, t.out_var])
            and C.single_step(base) == C.single_step(renamed)
            and len(C.conjuncts(s.post)) == len(C.conjuncts(t.post))
            and [fs for _, fs in C.intermediate_results(base)] == [fs for _, fs in C.intermediate_results(renamed)]
            and [(u, C.canon(c, [s.in_var, s.out_var])) for c, _, u in SC.unrealizable_conjuncts(base, lean=False)]
            == [(u, C.canon(c, [t.in_var, t.out_var])) for c, _, u in SC.unrealizable_conjuncts(renamed, lean=False)]
        )
        if not same:
            bad.append((run, rid))
    assert n > 400
    _fail_list(bad, "verdict changed under alpha-renaming")


def test_mr_s2_renaming_the_variables_gives_the_same_skeleton():
    bad, n = [], 0
    for run, rid, code in SPECS:
        defs = V.code_defs_only(code)
        s = C.spec_contract(defs)
        if s is None or not _renamable(code, s) or "_" in (s.in_var, s.out_var):
            continue
        n += 1
        fields = V.field_types(defs)
        a = SK.build(s, fields)
        b = SK.build(C.spec_contract(_rename_spec(code, s, ("zp", "zi", "zo"))), fields)
        if (a.values, a.how, len(a.hints)) != (b.values, b.how, len(b.hints)):
            bad.append((run, rid))
    assert n > 400
    _fail_list(bad, "skeleton changed under alpha-renaming")


def test_mr_s3_the_order_of_post_conditions_does_not_change_what_is_derived():
    """`a ∧ b` and `b ∧ a` are the same contract: the same fields are derived / left as holes,
    the same split decision is taken."""
    bad, n = [], 0
    for run, rid, code in SPECS:
        defs = V.code_defs_only(code)
        s = C.spec_contract(defs)
        parts = C.conjuncts(s.post) if s else []
        if s is None or len(parts) < 2 or "_" in (s.in_var, s.out_var):
            continue
        n += 1
        rev = C.Contract(s.name, s.dom, s.cod, s.pre_var, s.pre, s.in_var, s.out_var,
                         " ∧ ".join(f"({c})" for c in reversed(parts)))
        fields = V.field_types(defs)
        a, b = SK.build(s, fields), SK.build(rev, fields)
        flipped = C.replace_contract(defs, rev)
        ok = (sorted(C.conjuncts(rev.post)) == sorted(parts)
              and {f for f, h in a.how.items() if h == "hole"} == {f for f, h in b.how.items() if h == "hole"}
              and a.complete == b.complete
              and (C.single_step(defs) is None) == (C.single_step(flipped) is None)
              and sorted(c for c, _, _ in SC.unrealizable_conjuncts(defs, lean=False))
              == sorted(c for c, _, _ in SC.unrealizable_conjuncts(flipped, lean=False)))
        if not ok:
            bad.append((run, rid))
    assert n > 150
    _fail_list(bad, "result depends on the order of the conjuncts of `post`")


def test_mr_s4_comments_and_blank_lines_change_no_parse():
    bad = []
    for run, rid, code in SPECS:
        noisy = "-- generated\n\n" + code.replace("\ndef Spec", "\n-- the contract\ndef Spec") + "\n\n-- end\n"
        if C.spec_contract(noisy) != C.spec_contract(code) or \
                V.field_types(noisy) != V.field_types(code) or \
                V.example_witness(noisy) != V.example_witness(code) or \
                V.check_contradictions(noisy) != V.check_contradictions(code) or \
                V.trivial_nat_bounds(noisy) != V.trivial_nat_bounds(code):
            bad.append((run, rid))
    _fail_list(bad, "a comment changed what the harness reads")


def test_mr_s5_a_recorded_spec_is_a_fixed_point_of_the_harness_text_passes():
    """What the pipeline stored has already been through extraction and fixups: doing either
    again (in any wrapping) must give the same code back."""
    bad = []
    for run, rid, code in SPECS:
        if apply_fixups(code) != (code, []):
            bad.append((run, rid, "fixups"))
        for reply in (f"```lean\n{code}\n```", f"Here is the spec.\n\n```lean4\n{code}\n```\nDone.",
                      f"<think>\nhmm\n</think>\n```\n{code}\n```", f"```lean\n{code}"):
            if extract_lean(reply) != code.strip():
                bad.append((run, rid, "extract"))
                break
    _fail_list(bad, "stored spec is not a fixed point")


def test_mr_s6_example_literals_survive_reformatting():
    """one_line(literal) and the literal written over several lines name the same fields."""
    bad, n = [], 0
    for run, rid, code in SPECS:
        w = V.example_witness(code)
        if not w:
            continue
        n += 1
        for lit in w:
            fields = V.literal_fields(lit)
            if not fields:
                continue
            spread = "{\n    " + ",\n    ".join(f"{k} :=\n      {v}" for k, v in fields.items()) + "\n  }"
            if V.one_line(spread) != V._literal(fields) or V.literal_fields(V.one_line(spread)) != fields:
                bad.append((run, rid))
    assert n > 400
    _fail_list(bad, "record literal changed under reformatting")


# ---------------------------------------------------------------------------
# MR-A: L1 architectures (corpus: every accepted two-component architecture)
# ---------------------------------------------------------------------------

ARCHS = corpus.chain_architectures()


def _summary(result: dict) -> tuple:
    f = result["facts"]
    return (len(result["problems"]), f.get("a"), f.get("b"), f.get("mid"), f.get("carried"), f.get("derived"),
            f.get("strength"), len(f.get("first_work") or []), len(f.get("second_work") or []))


def _defs(arch: str) -> str:
    return C.strip_theorems(arch)


def test_mr_a1_renaming_contract_variables_changes_no_fact():
    bad, n = [], 0
    for rep, rid, spec, arch in ARCHS:
        defs = _defs(arch)
        cs = [c for c in C.parse_contracts(defs) if c.name != "Spec"]
        if len(cs) != 2 or any(not _renamable(defs, c) for c in cs):
            continue
        n += 1
        renamed = defs
        for k, c in enumerate(cs):
            renamed = C.replace_contract(renamed, _renamed(c, (f"zp{k}", f"zi{k}", f"zo{k}")))
        if _summary(C.static_check(defs, spec)) != _summary(C.static_check(renamed, spec)):
            bad.append((rep, rid))
    assert n > 40
    _fail_list(bad, "static_check changed under alpha-renaming")


def test_mr_a2_the_order_of_the_two_definitions_does_not_matter():
    bad = []
    for rep, rid, spec, arch in ARCHS:
        defs = C.strip_comments(_defs(arch))
        blocks = [m.group(0) for m in C._DEF_CONTRACT.finditer(defs)]
        if len(blocks) != 2:
            continue
        head = defs[:defs.index(blocks[0])]
        swapped = head + blocks[1].rstrip() + "\n\n" + blocks[0].rstrip() + "\n"
        a, b = C.static_check(defs, spec), C.static_check(swapped, spec)
        if _summary(a) != _summary(b) or a["problems"] != b["problems"]:
            bad.append((rep, rid))
    _fail_list(bad, "static_check depends on which contract is written first")


def test_mr_a3_comments_change_no_fact_and_recorded_architectures_still_pass():
    bad, rejected = [], []
    for rep, rid, spec, arch in ARCHS:
        defs = _defs(arch)
        base = C.static_check(defs, spec)
        noisy = "-- architecture\n" + defs.replace("\ndef ", "\n-- a component\ndef ") + "\n-- end\n"
        if C.static_check(noisy, spec) != base:
            bad.append((rep, rid))
        if base["problems"]:
            rejected.append((rep, rid, base["problems"][0][:80]))
    _fail_list(bad, "a comment changed static_check")
    # Replay: what the run accepted, the current static check accepts too.
    _fail_list(rejected, "an accepted architecture is rejected by the current static check")


def test_mr_a4_carrying_input_fields_is_idempotent():
    """carry_input_fields makes Input fields visible to the second contract; a second pass has
    nothing left to carry."""
    bad = []
    for rep, rid, spec, arch in ARCHS:
        once, added = C.carry_input_fields(_defs(arch), spec)
        twice, more = C.carry_input_fields(once, spec)
        if more or (added and C.parse_contracts(twice) != C.parse_contracts(once)):
            bad.append((rep, rid, added, more))
    _fail_list(bad, "carry_input_fields is not idempotent")


# ---------------------------------------------------------------------------
# MR-F: repair feedback
# ---------------------------------------------------------------------------

@given(S.lean_errors(min_size=1), S.spec_models(), st.integers(1, 40))
def test_mr_f1_a_locked_context_only_shifts_the_error_positions(errors, m, n_ctx):
    """The same errors, reported `len(context)` lines further down with that context given,
    produce the same feedback as without a context."""
    code = m.code()
    context = "\n".join(f"-- locked {k}" for k in range(n_ctx))
    shift = context.count("\n") + 2
    base = HEADER.count("\n")
    here = [{**e, "line": base + 1 + e["line"] % len(code.splitlines())} for e in errors]
    moved = [{**e, "line": e["line"] + shift} for e in here]
    assert R.format_feedback(code, S.render_lean_output(moved), context=context) == \
        R.format_feedback(code, S.render_lean_output(here))


@given(S.lean_errors(min_size=1), st.integers(1, 300), st.integers(0, 60))
def test_mr_f2_failure_class_and_stage_do_not_depend_on_positions(errors, dl, dc):
    moved = [{**e, "line": e["line"] + dl, "col": e["col"] + dc} for e in errors]
    a, b = S.render_lean_output(errors), S.render_lean_output(moved)
    assert classify(a) == classify(b)
    assert R.earliest_stage(a) == R.earliest_stage(b)
    assert R.error_signature(a) == R.error_signature(b)


@given(S.lean_errors(min_size=1), S.lean_errors())
def test_mr_f3_warnings_and_later_errors_do_not_change_the_first_error(errors, later):
    last = errors[-1]["line"]
    more = errors + [{**e, "line": e["line"] + last} for e in later]
    assert R.error_signature(S.render_lean_output(errors, noise=True)) == R.error_signature(S.render_lean_output(more))
    assert R.parse_errors(S.render_lean_output(more))[:len(errors)] == errors


# ---------------------------------------------------------------------------
# MR-E: evaluation scripts
# ---------------------------------------------------------------------------

def _write_run(folder, reps):
    for k, d in enumerate(reps, 1):
        rep = folder / f"rep{k}"
        rep.mkdir(parents=True)
        (rep / "l1l2.json").write_text(json.dumps(d), encoding="utf-8")
    return folder


def _rows(report: str) -> dict:
    """{metric: cell} of the first table of a report."""
    table = report.split("### ")[0]
    return dict(re.findall(r"^\| ([^|]+?) \| ([^|]+?) \|$", table, re.MULTILINE)[1:])


@settings(max_examples=25)
@given(S.chain_runs(min_size=1), st.integers(2, 4))
def test_mr_e1_repeating_a_repetition_adds_no_spread(tmp_path_factory, d, k):
    one = _rows(E.report(_write_run(tmp_path_factory.mktemp("one"), [d])))
    many = _rows(E.report(_write_run(tmp_path_factory.mktemp("many"), [d] * k)))
    assert one.keys() == many.keys()
    for key, cell in many.items():
        m = re.fullmatch(r"([\d.]+) \(([\d.e+-]+)–([\d.e+-]+)\)", cell)
        assert m and float(m.group(2)) == float(m.group(3)), (key, cell)
        assert abs(float(m.group(1)) - float(one[key])) <= 0.0051, (key, cell, one[key])


@settings(max_examples=25)
@given(S.chain_runs(min_size=1), S.chain_runs(min_size=1))
def test_mr_e2_counts_do_not_depend_on_the_order_of_the_repetitions(tmp_path_factory, d1, d2):
    ab = _rows(E.report(_write_run(tmp_path_factory.mktemp("ab"), [d1, d2])))
    ba = _rows(E.report(_write_run(tmp_path_factory.mktemp("ba"), [d2, d1])))
    common = [k for k in ab if k in ba and not k.startswith("strength")]
    assert len(common) >= 12
    assert all(ab[k] == ba[k] for k in common)


def _chain_rep(with_chain: bool) -> list:
    ok = {"contract": "Spec", "success": True, "attempts": 1, "error": "", "error_class": None, "stages": ["ok"],
          "code": "", "harness_only": False, "fields": {"harness": [], "model": ["a"]}}
    l1 = {"success": True, "attempts": 1, "error": "", "error_class": None, "stages": [], "code": ""}
    single = {"id": "R1", "kind": "requirement", "l1": {**l1, "mode": "single", "contracts": ["Spec"], "strength": None},
              "l2": [ok], "full_check": True, "seconds": 1.0}
    chain = {"id": "R2", "kind": "requirement",
             "l1": {**l1, "mode": "chain", "contracts": ["A", "B"], "strength": {"score": 5, "of": 6}},
             "l2": [{**ok, "contract": "A"}, {**ok, "contract": "B"}], "full_check": True, "seconds": 1.0}
    other = {**single, "id": "R2"}
    return [single, chain if with_chain else other]


@pytest.mark.xfail(strict=True, reason="FINDING: report() takes its rows from the first repetition and fills a missing "
                                       "metric with 0. `strength of chain architectures` exists only in repetitions "
                                       "that accepted a chain: with (chain, none) it is reported as 2.50 (0–5) instead "
                                       "of 5.00, with (none, chain) the row disappears. 10 of 89 recorded runs are affected")
def test_mr_e3_the_strength_row_does_not_depend_on_which_repetition_has_a_chain(tmp_path):
    with_first = _rows(E.report(_write_run(tmp_path / "a", [_chain_rep(True), _chain_rep(False)])))
    with_last = _rows(E.report(_write_run(tmp_path / "b", [_chain_rep(False), _chain_rep(True)])))
    key = "strength of chain architectures (of 6)"
    assert key in with_first and key in with_last
    assert with_first[key] == with_last[key]
    assert with_first[key].startswith("5.00")                       # the mean over the chains that exist


@settings(max_examples=25)
@given(S.chain_runs(min_size=2), st.data())
def test_mr_e4_shard_files_load_as_the_whole_run(tmp_path_factory, d, data):
    """`e2e_l1l2.py` writes l1l2.<a>-<b>.json shards; a run split into shards is the same run."""
    cut = data.draw(st.integers(1, len(d) - 1))
    whole = tmp_path_factory.mktemp("whole")
    (whole / "l1l2.json").write_text(json.dumps(d), encoding="utf-8")
    parts = tmp_path_factory.mktemp("parts")
    (parts / f"l1l2.0-{cut}.json").write_text(json.dumps(d[:cut]), encoding="utf-8")
    (parts / f"l1l2.{cut}-{len(d)}.json").write_text(json.dumps(d[cut:] + d[:1]), encoding="utf-8")  # an overlap
    loaded = E.load_rep(parts)
    assert sorted(e["id"] for e in loaded) == sorted(e["id"] for e in d)
    assert E.metrics(loaded, {}) == E.metrics(E.load_rep(whole), {})


@pytest.mark.parametrize("run", corpus.sample(sorted(corpus.RUNS.glob("*/qwen-v11")), 6), ids=lambda p: p.parent.name)
def test_mr_e5_a_run_compared_with_itself_is_the_same_everywhere(run):
    report = CR.report(run, run)
    verdicts = re.findall(r"\| ([^|]+) \|$", report, re.MULTILINE)
    assert "**better**" not in report and "**worse**" not in report
    assert sum(v.strip() == "same" for v in verdicts) >= 9


@pytest.mark.parametrize("run", corpus.sample(sorted(corpus.RUNS.glob(f"*/{corpus.LATEST_CHAIN}")), 6),
                         ids=lambda p: p.parent.name)
def test_mr_e6_real_runs_keep_their_counts_when_repetitions_are_reordered(run, tmp_path):
    reps = [E.load_rep(p) for p in sorted(run.glob("rep*")) if (p / "l1l2.json").exists()]
    if len(reps) < 2:
        pytest.skip("one repetition")
    fwd = _rows(E.report(_write_run(tmp_path / "fwd", reps)))
    rev = _rows(E.report(_write_run(tmp_path / "rev", reps[::-1])))
    for key in fwd:
        if key in rev and not key.startswith("strength"):
            assert fwd[key] == rev[key], key
