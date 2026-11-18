"""Contract tests on the recorded outputs (no Lean, no model).

The stages of the pipeline only meet through files. Each test here states what a *consumer*
relies on and checks every recorded file of the producer against it:

    parser  → L0 / L0.5 / graph     Requirements/parsed/*.json     schema, golden re-parse, ids
    L0      → chain path            specs.json, review.json        schema, counts, accepted set
    chain   → evaluation, readers   chain_meta.json, l1l2.json,    schema, cross-field invariants,
                                    l1l2/*.lean                    replay of the deterministic parts
    evaluation → documents          summary.md, results.md, README numbers recomputed from the data

"Replay" means: recompute with today's code what the run stored (failure classes, the
end-to-end theorem text, the Lean file, the provenance of each field, the report rows) and
compare. A mismatch is either drift in the code or a defect in what was stored.

KNOWN_* constants list deviations that exist in the recorded data today, with the reason.
They are asserted exactly: a new deviation fails, and so does a fix that is not recorded here.
"""
import collections
import re
import statistics

import jsonschema
import pytest

import arch_lean as A
import chain_checks as C
import chain_pipeline as CP
import po
import req_parser as P
import skeleton as SK
import summarize_e2e as E
import validate as V
from chain_failures import CLASSES, classify

from . import corpus, schemas
from .test_pbt_text import _valid_for

ROOT = corpus.ROOT


def _validate(instance, schema, where: str):
    errors = sorted(jsonschema.Draft202012Validator(schema).iter_errors(instance), key=lambda e: list(e.absolute_path))
    assert not errors, f"{where}: {len(errors)} schema error(s), first at {list(errors[0].absolute_path)}: {errors[0].message[:300]}"


def _none(bad, what):
    assert not bad, f"{what}: {len(bad)} case(s), e.g. {bad[:3]}"


# ---------------------------------------------------------------------------
# Parser → everything downstream
# ---------------------------------------------------------------------------

# Stored specs that passed when they were checked but that the H4 fix (field types with a
# trailing `-- comment`) now correctly flags: `0 ≤ i.trainLocation` where the type was
# `Nat -- location …`, so the trivial-Nat-bound check could not see the `Nat` before.
_CAUGHT_AFTER_H4 = {("2007-ertms", "4.3.4.2")}


@pytest.mark.parametrize("xml", corpus.srs_documents(), ids=lambda p: p.stem)
def test_parsed_json_is_what_the_parser_writes_today(xml):
    """Golden: the committed parse is byte-identical to a fresh parse (same XML bytes → same JSON bytes)."""
    stored = (corpus.REQUIREMENTS / "parsed" / f"{xml.stem}.json").read_text(encoding="utf-8")
    assert P.to_json(P.parse_file(xml)) == stored


@pytest.mark.parametrize("path", corpus.parsed_documents(), ids=lambda p: p.stem)
def test_parsed_document_contract(path):
    doc = corpus.load(path)
    _validate(doc, schemas.PARSED_DOC, path.name)
    entries = doc["requirements"] + doc["data_dictionary"] + doc["use_cases"]
    assert doc["stats"] == {"requirements": len(doc["requirements"]), "data_constraints": len(doc["data_dictionary"]),
                            "use_cases": len(doc["use_cases"]), "dropped": len(doc["dropped"])}
    ids = [e["id"] for e in entries]
    assert len(ids) == len(set(ids))
    # Consumers turn an id into a Lean namespace (arch_lean.slug) and a file name: both must stay unique.
    assert len({A.slug(i) for i in ids}) == len(ids)
    assert len({re.sub(r"[^\w.-]", "_", i) for i in ids}) == len(ids)
    for r in doc["requirements"]:
        assert (r["category"] == "performance") == ("runtime_checks" in r) == (r["verification"] != "lean")
        assert r["category"] != "functional" or not r["quantities"]
        for c in r.get("runtime_checks", []):
            assert c["bound"] >= 0
    for u in doc["use_cases"]:
        steps = [s["step"] for s in u["basic_scenario"]]
        assert steps == sorted(steps)
        for s in u["basic_scenario"] + [s for f in u["alternative_scenarios"] for s in f["steps"]]:
            if "goto" in s:                                         # a jump lands on a kept step or the end
                assert s["goto"]["resolves_to"] == "end" or s["goto"]["resolves_to"] in steps


def test_every_data_constraint_yields_correctly_labelled_test_values():
    """validate.data_cases consumes `constraints`: for every data-dictionary entry of every SRS,
    the generated values are valid exactly when they are labelled valid."""
    bad, n = [], 0
    for path in corpus.parsed_documents():
        for d in corpus.load(path)["data_dictionary"]:
            for value, ok, why in V.data_cases(d["constraints"]):
                n += 1
                if _valid_for(value, d["constraints"]) != ok:
                    bad.append((path.stem, d["id"], value, why))
    assert n > 40
    _none(bad, "data test value mislabelled")


# ---------------------------------------------------------------------------
# L0 → chain path
# ---------------------------------------------------------------------------

L0_REPS = corpus.l0_reps()
# summary.compiles was counted before the L0.5 loop finished; in these files it is off by one
# or more from the number of results with `compiles: true` (rep1 of the v11 run only).
KNOWN_COMPILES_COUNT_OFF = {
    "runs/0000 - cctns/qwen-v11/rep1", "runs/1998 - themas/qwen-v11/rep1", "runs/1999 - tcs/qwen-v11/rep1",
    "runs/2005 - phin/qwen-v11/rep1", "runs/2006 - eirene sys 15/qwen-v11/rep1", "runs/2007-ertms/qwen-v11/rep1",
    "runs/2008 - keepass/qwen-v11/rep1", "runs/2009 - peppol approved/qwen-v11/rep1"}


def test_l0_corpus_is_present():
    assert len(L0_REPS) >= 40


@pytest.mark.parametrize("rep", L0_REPS, ids=corpus.rel)
def test_l0_run_contract(rep):
    specs = corpus.load(rep / "specs.json")
    _validate(specs, schemas.SPECS, corpus.rel(rep))
    review = corpus.load(rep / "review.json")
    _validate(review, schemas.REVIEW, corpus.rel(rep))
    rs = specs["results"]
    ids = [r["id"] for r in rs]
    assert len(ids) == len(set(ids)) and set(review) == set(ids)
    assert specs["summary"]["total"] == len(rs)
    assert specs["summary"]["checked"] == sum(r["checked"] is True for r in rs)
    assert specs["l05_summary"] == {k: sum(r["l05"]["status"] == k for r in rs) for k in ("pass", "flag", "fail")}
    parsed = corpus.load(corpus.REQUIREMENTS / "parsed" / (specs["source"]["file"][:-4] + ".json"))
    assert specs["source"]["sha256"] == parsed["source"]["sha256"]          # the run is of this very document
    known = {e["id"]: e for e in parsed["requirements"] + parsed["data_dictionary"] + parsed["use_cases"]}
    for r in rs:
        assert r["id"] in known and r["kind"] == known[r["id"]]["kind"]
        assert review[r["id"]]["status"] == r["l05"]["status"]
        if r["checked"]:
            assert r["compiles"] is True and r["l05"]["status"] != "fail"
        if not r["compiles"]:
            assert r["l05"] == {"status": "fail", "problems": ["does not compile"], "flags": []}
        assert (r["l05"]["status"] == "fail") == bool(r["l05"]["problems"])
        assert r["l05"]["status"] != "flag" or r["l05"]["flags"]
    accepted = CP.accepted_specs(rep)
    assert all(r["checked"] is True and review[r["id"]]["decision"] == "accept" for r in accepted)
    assert [r["id"] for r in accepted] == [i for i in ids if i in {r["id"] for r in accepted}]   # document order


def test_l0_summary_compiles_count():
    off = {corpus.rel(rep) for rep in L0_REPS
           if "compiles" in (s := corpus.load(rep / "specs.json"))["summary"]
           and s["summary"]["compiles"] != sum(r["compiles"] is True for r in s["results"])}
    assert off == KNOWN_COMPILES_COUNT_OFF


@pytest.mark.parametrize("rep", L0_REPS, ids=corpus.rel)
def test_every_checked_spec_has_the_shape_l1_expects(rep):
    """The chain path reads `Spec : Contract Input Output`, the two structures and the example."""
    bad = []
    for r in corpus.load(rep / "specs.json")["results"]:
        if not r["checked"]:
            continue
        code = r["lean_predicate"]
        s = C.spec_contract(code)
        types = V.field_types(code)
        if s is None or (s.dom, s.cod) != ("Input", "Output") or "Input" not in types or "Output" not in types:
            bad.append((r["id"], "shape"))
        elif (V.check_housekeeping(code) or po.forbidden_words(code)) and (rep.parts[-3], r["id"]) not in _CAUGHT_AFTER_H4:
            bad.append((r["id"], "housekeeping"))
        elif not V.example_witness(code):
            bad.append((r["id"], "no example witness"))
        elif set(C._refs(s.post, s.out_var)) - set(types["Output"]) or set(C._refs(s.pre, s.pre_var)) - set(types["Input"]):
            bad.append((r["id"], "reads an undeclared field"))
    _none(bad, f"{corpus.rel(rep)}: checked spec not in the expected shape")


# ---------------------------------------------------------------------------
# Chain path → evaluation and readers
# ---------------------------------------------------------------------------

CHAIN_REPS = corpus.chain_reps()
# skeleton._impl_record takes the text ` with ` inside a string literal for a record update
# (`{ x with … }`), gives up, and provenance then credits every field to the model although the
# harness skeleton alone implemented the component (CI-1 of gamma j: "… with tracking number …").
KNOWN_HARNESS_ONLY_CREDITED_TO_MODEL = {
    (f"runs/0000 - gamma j/{run}/rep{k}", "CI-1") for run in ("qwen-chain-v5", "qwen-chain-v5-fallback") for k in (1, 2, 3)}

# Stored before the H1 fix (a string literal containing " with " was read as `{ x with … }`):
# their stored `fields` credit skeleton fields to the model. Recomputed today: CI-1's two fields
# are the harness's; in peppol 1.1/S4 GenerateNoticeContract, `included` is the harness's.
STORED_BEFORE_H1_FIX = KNOWN_HARNESS_ONLY_CREDITED_TO_MODEL | {
    (f"runs/2009 - peppol approved/{run}/rep3", "1.1/S4") for run in ("qwen-chain-v5", "qwen-chain-v5-fallback")}


def test_chain_corpus_is_present():
    assert len(CHAIN_REPS) >= 200 and sum(len(corpus.records(r)) for r in CHAIN_REPS) >= 7000


@pytest.mark.parametrize("rep", CHAIN_REPS, ids=corpus.rel)
def test_chain_run_contract(rep):
    meta, recs = corpus.meta(rep), corpus.records(rep)
    _validate(meta, schemas.CHAIN_META, corpus.rel(rep))
    _validate(recs, schemas.CHAIN_RUN, corpus.rel(rep))
    name = rep.parent.name
    assert meta["harness_version"] in name and meta["fallback_single"] == ("fallback" in name)
    assert rep.name == f"rep{meta['repetition']}" and meta["seed"] == 41 + meta["repetition"]
    # The run covers exactly the accepted specs of its L0 run, in order, each with one Lean file.
    l0 = ROOT / meta["l0_run"]
    assert [e["id"] for e in recs] == [r["id"] for r in CP.accepted_specs(l0)]
    assert sorted(p.name for p in (rep / "l1l2").glob("*.lean")) == sorted(corpus.lean_path(rep, e["id"]).name for e in recs)
    specs = corpus.l0_specs(rep)
    for e in recs:
        assert "crash" not in e
        l1, l2, where = e["l1"], e["l2"], (corpus.rel(rep), e["id"])
        assert (e["kind"], e["requirement_text"]) == (specs[e["id"]]["kind"], specs[e["id"]]["requirement_text"]), where
        # L1
        assert l1["success"] == (not l1["error"]) == (l1["error_class"] is None), where
        if l1["success"]:
            assert l1["contracts"] == (["Spec"] if l1["mode"] != "chain" else l1["contracts"]) and \
                len(l1["contracts"]) == (2 if l1["mode"] == "chain" else 1), where
        assert (l1["mode"] != "chain") == ("why_single" in l1) or not l1["success"], where
        assert (l1["mode"] in ("single-fallback", "single-not-decomposable")) == ("failed_split" in l1), where
        if l1["mode"] == "single-fallback":
            assert meta["fallback_single"], where
        if l1["success"] and l1["mode"] == "chain":
            assert 0 <= l1["strength"]["score"] <= l1["strength"]["of"], where
            assert re.search(r"^theorem po1 : Contract\.Compatible ", l1["code"], re.M), where
            assert re.search(r"^theorem po2 : Contract\.Refines ", l1["code"], re.M), where
        elif l1["success"]:
            assert "theorem po2 : Contract.Refines Spec Spec" in l1["code"], where
        assert not po.forbidden_words(l1["code"]) or not l1["success"], where
        # L2: one record per contract of an accepted architecture, none otherwise
        assert [x["contract"] for x in l2] == (l1["contracts"] if l1["success"] else []), where
        for x in l2:
            assert x["success"] == (not x["error"]) == (x["error_class"] is None), where
            if x["success"]:
                c = x["contract"]
                assert re.search(rf"^def {c}Impl\b", x["code"], re.M), where
                assert re.search(rf"^theorem {c}Impl_ok : {c}\.Satisfies {c}Impl\b", x["code"], re.M), where
                assert not po.forbidden_words(x["code"]), where
        # End to end: the theorem exists exactly when every part succeeded, and Lean accepted it
        done = bool(l2) and all(x["success"] for x in l2)
        assert ("system_theorem" in e) == ("full_check" in e) == done, where
        if done:
            assert e["system_theorem"] == CP.system_theorem(l1["contracts"]), where
            assert e["full_check"] is True, where
        sc = e.get("spec_check")
        if sc:
            assert sc["trivial"] == ("witness" in sc), where
            if sc.get("l05_class"):                                 # the L0.5 class and the chain run's own check agree
                assert sc["trivial"] == (sc["l05_class"] in ("weak", "copy-ok")), where
                assert sc["copy_ok"] == (sc["l05_class"] == "copy-ok") or not sc["trivial"], where


@pytest.mark.parametrize("rep", CHAIN_REPS, ids=corpus.rel)
def test_failure_classes_replay(rep):
    """chain_failures.classify is deterministic: the stored class is today's class of the stored error."""
    bad = []
    for e in corpus.records(rep):
        for part in [e["l1"], e["l1"].get("failed_split") or {}] + e["l2"]:
            if "error" in part:
                now = classify(part["error"], part.get("stages"))
                if part.get("error_class") != now or (now is not None and now not in CLASSES):
                    bad.append((e["id"], part.get("error_class"), now))
    _none(bad, f"{corpus.rel(rep)}: stored failure class differs from classify()")


@pytest.mark.parametrize("rep", CHAIN_REPS, ids=corpus.rel)
def test_lean_files_replay(rep):
    """l1l2/<id>.lean is exactly chain_pipeline.lean_file(spec, record)."""
    specs = corpus.l0_specs(rep)
    bad = [e["id"] for e in corpus.records(rep)
           if corpus.lean_path(rep, e["id"]).read_text(encoding="utf-8") != CP.lean_file(specs[e["id"]], e)]
    _none(bad, f"{corpus.rel(rep)}: Lean file differs from lean_file()")


def _v5(rep) -> bool:
    return "chain-v5" in rep.parent.name


@pytest.mark.parametrize("rep", [r for r in CHAIN_REPS if _v5(r)], ids=corpus.rel)
def test_field_provenance_replay(rep):
    """`fields` says who wrote each result field. It must name exactly the fields of the
    contract's result structure, and equal skeleton.provenance of the stored code today."""
    specs, bad, credited, changed = corpus.l0_specs(rep), [], set(), set()
    for e in corpus.records(rep):
        locked = specs[e["id"]]["lean_predicate"] + "\n\n" + e["l1"]["code"]
        types = V.field_types(locked)
        contracts = {c.name: c for c in C.parse_contracts(locked)}
        for x in e["l2"]:
            f, c = x.get("fields"), contracts.get(x["contract"])
            if not f or c is None:
                continue
            if sorted(f["harness"] + f["model"]) != sorted(types.get(c.cod, {})) or set(f["harness"]) & set(f["model"]):
                bad.append((e["id"], "fields are not the result structure's", f))
            now = SK.provenance(x["code"], SK.build(c, types, f"{c.name}Impl")) if x["success"] else f
            if now != f:
                changed.add((corpus.rel(rep), e["id"]))
                if (corpus.rel(rep), e["id"]) not in STORED_BEFORE_H1_FIX:
                    bad.append((e["id"], "provenance differs", f))
            if x.get("harness_only"):
                if x["attempts"] != 0 or not x["success"]:
                    bad.append((e["id"], "harness_only with model attempts", x["attempts"]))
                if f["model"]:
                    credited.add((corpus.rel(rep), e["id"]))
    _none(bad, corpus.rel(rep))
    assert changed == {k for k in STORED_BEFORE_H1_FIX if k[0] == corpus.rel(rep)}, "H1 corrections changed"
    assert credited == {k for k in KNOWN_HARNESS_ONLY_CREDITED_TO_MODEL if k[0] == corpus.rel(rep)}


def test_provenance_ignores_the_word_with_inside_a_string_literal():
    spec = ("structure Input where\n  n : Nat\n  deriving DecidableEq, Repr\n\nstructure Output where\n  msg : String\n"
            "  deriving DecidableEq, Repr\n\ndef Spec : Contract Input Output where\n  pre := fun i => True\n"
            '  post := fun i o => o.msg = "sent with care"\n')
    sk = SK.build(C.spec_contract(spec), V.field_types(spec))
    assert sk.complete
    assert SK.provenance(SK.render(sk), sk) == {"harness": ["msg"], "model": []}


# ---------------------------------------------------------------------------
# Evaluation → documents
# ---------------------------------------------------------------------------

def _table_rows(text: str) -> dict:
    return dict(re.findall(r"^\| ([^|]+?) \| ([^|]+?) \|$", text, re.MULTILINE))


_SUMMARIES = [p for p in sorted(corpus.RUNS.glob("*/*/summary.md")) if "damaged" not in str(p)]
_CORE_ROWS = ("specs", "L1 accepted", "L1 chain (two components)", "L2 components implemented", "L2 components total",
              "end to end", "end to end, chain", "end to end, non-trivial spec")


@pytest.mark.parametrize("path", _SUMMARIES, ids=corpus.rel)
def test_summary_md_numbers_are_reproduced_from_l1l2_json(path, monkeypatch):
    """Each `## <run>` section of a committed summary.md: its headline rows are what
    summarize_e2e computes from the run's l1l2.json today."""
    monkeypatch.chdir(ROOT)
    checked = 0
    for section in re.split(r"(?m)^(?=## )", path.read_text(encoding="utf-8")):
        m = re.match(r"## (.+)\n", section)
        run = ROOT / m.group(1).strip() if m else None
        if run is None or not run.is_dir() or not (list(run.glob("rep*/l1l2*.json")) or list(run.glob("l1l2*.json"))):
            continue
        old, new = _table_rows(section), _table_rows(E.report(run.relative_to(ROOT)))
        for key in _CORE_ROWS:
            if key in old:
                assert old[key] == new.get(key), (m.group(1), key)
                checked += 1
    assert checked or "L1-v1" in str(path) or "v10" in str(path)


def _per_srs(name: str) -> dict:
    """{srs: (mean specs, mean end to end, mean non-trivial end to end)} of a chain run over its repetitions."""
    out = {}
    for run in sorted(corpus.RUNS.glob(f"*/{name}")):
        reps = [corpus.records(r) for r in corpus.chain_reps((name,)) if r.parent == run]
        if reps:
            e2e = lambda d: [e for e in d if e.get("full_check") is True]  # noqa: E731
            out[run.parent.name] = (statistics.mean(len(d) for d in reps), statistics.mean(len(e2e(d)) for d in reps),
                                    statistics.mean(sum(not (e.get("spec_check") or {}).get("trivial") for e in e2e(d))
                                                    for d in reps))
    return out


_RESULTS_COLUMNS = ["qwen-chain-v4", "qwen-chain-v5-on-v10.1", "qwen-chain-v5", "qwen-chain-v5-fallback"]
# results.md prints `–` for peering under "chain-v5 on v10.1 L0", but the run exists and verified
# its one spec (runs/2008 - peering/qwen-chain-v5-on-v10.1); the column total 372.0 leaves it out.
KNOWN_RESULTS_MD_CELLS = {("2008 - peering", "qwen-chain-v5-on-v10.1"): ("–", 1.0)}


def test_results_md_per_srs_table_matches_the_runs():
    text = (ROOT / "results.md").read_text(encoding="utf-8")
    table = text.split("## Per SRS (end to end)")[1].split("## ")[0]
    data = {name: _per_srs(name) for name in _RESULTS_COLUMNS}
    off, n = {}, 0
    for line in table.splitlines():
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) != 6 or cells[0] in ("SRS", "---") or cells[0].startswith("**"):
            continue
        srs = cells[0]
        for name, cell in zip(_RESULTS_COLUMNS, cells[2:]):
            n += 1
            have = data[name].get(srs)
            shown = None if cell == "–" else float(cell.split()[0])
            actual = None if have is None or have[0] == 0 else round(have[1], 2)
            if shown != actual:
                off[(srs, name)] = (cell, actual)
    assert n == 72
    assert off == KNOWN_RESULTS_MD_CELLS


@pytest.mark.parametrize("name,specs,e2e,nontrivial", [
    ("qwen-chain-v5", 517, 390.3, 193.3), ("qwen-chain-v5-fallback", 517, 400.7, 200.0),
    ("qwen-chain-v4", 484, 344.3, 149.7)])
def test_headline_numbers_are_the_sum_over_the_srs(name, specs, e2e, nontrivial):
    """README.md / results.md headline: sum over the SRS of the mean over the 3 seeds."""
    per = _per_srs(name)
    assert round(sum(v[0] for v in per.values())) == specs
    assert round(sum(v[1] for v in per.values()), 1) == e2e
    assert round(sum(v[2] for v in per.values()), 1) == nontrivial
    text = (ROOT / "results.md").read_text(encoding="utf-8") + (ROOT / "README.md").read_text(encoding="utf-8")
    shown = e2e if name != "qwen-chain-v4" else 343.3                # results.md leaves peering (1 spec) out of this row
    assert f"{shown}" in text and f"{nontrivial}" in text


def test_every_repetition_of_a_run_uses_the_same_specs_and_settings():
    """A spread over repetitions is only a spread over seeds if nothing else changed."""
    by_run = collections.defaultdict(list)
    for rep in CHAIN_REPS:
        by_run[rep.parent].append(corpus.meta(rep))
    bad = []
    for run, metas in by_run.items():
        same = lambda k: len({str(m.get(k)) for m in metas}) == 1  # noqa: E731
        if not all(same(k) for k in ("harness_version", "model_id", "temperature", "prompt_hash", "l0_prompt_hash",
                                     "split", "fallback_single")):
            bad.append(corpus.rel(run))
        if len({m["seed"] for m in metas}) != len(metas):
            bad.append((corpus.rel(run), "repeated seed"))
    _none(bad, "repetitions of one run differ in more than the seed")


# ---------------------------------------------------------------------------
# Requirements graph (L1 graph path)
# ---------------------------------------------------------------------------

@pytest.mark.parametrize("path", sorted(corpus.RUNS.glob("*/graph/graph.json")), ids=corpus.rel)
def test_graph_json_contract(path):
    g = corpus.load(path)
    ops = {o["id"] for o in g["operations"]}
    assert g["metrics"]["operations"] == len(ops) == len(g["operations"])
    assert g["metrics"]["groups"] == len(g["groups"]) and g["metrics"]["components"] == len(g["components"])
    assert all(e["src"] in ops and e["dst"] in ops and e["src"] != e["dst"] and e["reasons"] for e in g["edges"])
    in_components = [m for c in g["components"] for m in c["operations"]]
    assert len(in_components) == len(set(in_components))            # an operation is in one component
    assert set(in_components) | set(g["isolated_operations"]) == ops
    assert not set(in_components) & set(g["isolated_operations"])
    names = [c["id"] for c in g["components"]]
    assert len(names) == len(set(names)) and all(re.fullmatch(r"[A-Z][A-Za-z0-9]*", n) for n in names)
    for grp in g["groups"]:
        assert sorted(grp["order"]) == sorted(grp["components"])    # the chain order lists every component once
        members = sorted(m for c in g["components"] if c["group"] == grp["id"] for m in c["operations"])
        assert members == sorted(grp["operations"])
        assert grp["acyclic"] == (not grp["cycles"])
    lean = [o["lean_name"] for o in g["operations"]]
    assert len(lean) == len(set(lean)) and all(re.fullmatch(r"[a-z0-9_]+", n) for n in lean)
