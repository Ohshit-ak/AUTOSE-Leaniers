"""Property-based tests of the deterministic pipeline stages (no Lean, no model):

    req_parser.parse_bytes     on generated SRS documents
    summarize_e2e / compare_runs   on generated chain-run records
    req_graph                  ordering and grouping on generated graphs

The generators (tests/strategies.py) build inputs in the layout the real files have, so the
properties are statements about what the stage does with any document / run / graph.
"""
import collections
import itertools
import json
import re

import networkx as nx
import pytest
from hypothesis import assume, given, settings
from hypothesis import strategies as st

import compare_runs as CR
import req_graph as G
import req_parser as P
import summarize_e2e as E

from . import strategies as S

CONCURRENT = "The system shall support at least 100 concurrent users."
KEEPABLE = set(S.SENTENCES[:10]) - {CONCURRENT}   # modal + a state change, data relation or quantity
# an overview section keeps only statements with a quantity or a data relation (total, unique, …)
QUANTIFIED = {s for s in KEEPABLE if re.search(r"\d", s) or P.DATA_RELATION.search(s)}


def _section_class(title: str) -> str:
    low = title.lower()
    if any(x in low for x in P.EXCLUDED_SECTIONS):
        return "excluded"
    return "overview" if P.OVERVIEW_SECTIONS.search(title) else "plain"


def _statements(secs):
    """[(section class along the path, text)] for every statement the parser must assess."""
    out = []

    def walk(sec, path):
        classes = path + [_section_class(sec.title)]
        cls = "excluded" if "excluded" in classes else "overview" if "overview" in classes else "plain"
        texts = [r for r in sec.reqs if r != "None"] + [t for t in sec.items if t != "None"]
        if sec.prose:
            texts += P.sentences(P.clean(" ".join(sec.prose)))
        out.extend((cls, t) for t in texts)
        for c in sec.children:
            walk(c, classes)
    for s in secs:
        walk(s, [])
    return out


def _docs():
    """Documents whose prose has no bare `None` (it has no full stop, so it would glue to the next sentence)."""
    def clean(secs):
        for top in secs:
            for sec in top.walk():
                sec.prose = [p for p in sec.prose if p != "None"]
        return secs
    return S.documents().map(clean)


# ---------------------------------------------------------------------------
# Parser on generated documents
# ---------------------------------------------------------------------------

@given(_docs())
def test_every_statement_is_kept_or_dropped_exactly_once(secs):
    doc = P.parse_bytes(S.render_document(secs), "t.xml")
    statements = _statements(secs)
    assert len(doc["requirements"]) + len(doc["dropped"]) == len(statements)
    assert collections.Counter(r["text"] for r in doc["requirements"] + doc["dropped"]) == \
        collections.Counter(t for _, t in statements)
    assert doc["stats"] == {"requirements": len(doc["requirements"]), "data_constraints": 0, "use_cases": 0,
                            "dropped": len(doc["dropped"])}


@given(_docs())
def test_keep_or_drop_depends_only_on_the_text_and_the_kind_of_section(secs):
    doc = P.parse_bytes(S.render_document(secs), "t.xml")
    kept = collections.Counter(r["text"] for r in doc["requirements"])
    expected = collections.Counter()
    for cls, t in _statements(secs):
        if t in KEEPABLE and (cls == "plain" or (cls == "overview" and t in QUANTIFIED)):
            expected[t] += 1
    assert kept == expected
    assert all(d["reason"] and d["source"] == "requirement" for d in doc["dropped"])
    for d in doc["dropped"]:
        if d["text"] in KEEPABLE:                                   # a good statement is dropped only for its section
            assert d["reason"].startswith(("non-normative section", "overview section"))


@pytest.mark.xfail(strict=True, reason="FINDING: `100 concurrent users` / `500 simultaneous users` is not read as a "
                                       "quantity (COUNT_RE wants the noun right after the number), so the usual "
                                       "wording of a concurrency requirement is dropped as 'no … quantity to formalise'; "
                                       "only `100 users concurrently` reaches the `concurrency` runtime check")
@pytest.mark.parametrize("sentence", [CONCURRENT, "The system shall support up to 500 simultaneous users.",
                                      "The system shall handle 1,000 simultaneous requests."])
def test_a_concurrency_requirement_is_kept_whatever_the_word_order(sentence):
    reference = P.parse_bytes(S.render_document([S.Section("1", "Performance", ["The system shall support 100 users concurrently."], [], [])]), "t.xml")
    assert [c["metric"] for c in reference["requirements"][0]["runtime_checks"]] == ["concurrency"]
    doc = P.parse_bytes(S.render_document([S.Section("1", "Performance", [sentence], [], [])]), "t.xml")
    assert [c["metric"] for r in doc["requirements"] for c in r.get("runtime_checks", [])] == ["concurrency"]


@given(_docs())
def test_ids_are_unique_and_name_their_section(secs):
    doc = P.parse_bytes(S.render_document(secs), "t.xml")
    ids = [r["id"] for r in doc["requirements"] + doc["dropped"]]
    assert len(ids) == len(set(ids))
    sids = {sec.sid for top in secs for sec in top.walk()}
    for r in doc["requirements"] + doc["dropped"]:
        assert r["section"] in sids
        assert re.fullmatch(re.escape(r["section"]) + r"/[RSI]\d+", r["id"])


@given(_docs())
def test_kept_requirements_are_well_formed(secs):
    doc = P.parse_bytes(S.render_document(secs), "t.xml")
    for r in doc["requirements"]:
        checks = r.get("runtime_checks")
        assert r["category"] == ("performance" if checks else "quantitative" if r["quantities"] else "functional")
        assert r["verification"] == ("lean+python_runtime" if checks else "lean")
        assert P.MODAL.search(r["text"])
        assert r["signals"] or any(q["kind"] != "percent" for q in r["quantities"])
        assert r["has_precondition"] == bool(P.PRECONDITION_CUE.search(r["text"]))
        assert r["section_path"] and all(_section_class(t) != "excluded" for t in r["section_path"])
        for c in checks or []:
            assert isinstance(c["bound"], int) and c["lean_field"] in ("elapsedMicros", "perSecond", "concurrentUsers")
    assert json.loads(P.to_json(doc)) == doc and P.to_json(doc).endswith("\n")


@given(_docs())
def test_parsing_is_a_pure_function_of_the_bytes(secs):
    data = S.render_document(secs)
    a, b = P.parse_bytes(data, "a.xml"), P.parse_bytes(data, "b.xml")
    assert P.to_json({**a, "source": None}) == P.to_json({**b, "source": None})
    assert a["source"]["sha256"] == b["source"]["sha256"] and a["source"]["file"] == "a.xml"


# ---------------------------------------------------------------------------
# Evaluation: summarize_e2e
# ---------------------------------------------------------------------------

@given(S.chain_runs())
def test_metrics_obey_the_accounting_identities(d):
    m = E.metrics(d, {})
    n = len(d)
    assert m["specs"] == n
    assert m["L1 accepted"] == (m["L1 chain (two components)"] + m["L1 single (not split)"] + m["L1 single-fallback"]
                                + m["L1 not decomposable (identity split → single)"]) <= n
    assert m["end to end"] == m["end to end, chain"] + m["end to end, single"] <= m["L1 accepted"]
    assert m["L2 components implemented"] <= m["L2 components total"]
    assert m["L2 components total"] == sum(len(e["l2"]) for e in d)
    if d:
        assert m["weak specs (satisfied by copies and constants)"] + sum(
            not e["spec_check"]["trivial"] for e in d) == n
        assert m["end to end, non-trivial spec"] + sum(
            e["spec_check"]["trivial"] and e.get("full_check") is True for e in d) == m["end to end"]
        assert m["end to end, copy-ok spec"] <= m["weak specs that only pass data through (copy-ok)"]
        if any(e["l2"] for e in d):
            assert m["end to end, non-trivial spec, model wrote code"] <= m["end to end, non-trivial spec"]
        assert sum(v for k, v in m.items() if k.startswith("specs, ")) == n
        assert sum(v for k, v in m.items() if re.fullmatch(r"end to end, (requirement|data_constraint|use_case)", k)) \
            == m["end to end"]
    if any(e["l2"] for e in d):
        assert m["L2 implemented by the harness skeleton alone"] + m["L2 implemented with the model"] \
            == m["L2 components implemented"]
    assert abs(m["minutes"] * 60 - sum(e["seconds"] for e in d)) < 1e-6


_MEANS = ("L1 attempts per split spec", "strength of chain architectures")


@given(S.chain_runs(), st.randoms(use_true_random=False))
def test_metrics_do_not_depend_on_the_order_of_the_records(d, rnd):
    """Metamorphic: a run is a set of specs; shuffling l1l2.json changes no number."""
    shuffled = list(d)
    rnd.shuffle(shuffled)
    a, b = E.metrics(d, {}), E.metrics(shuffled, {})
    assert a.keys() == b.keys()
    assert all(abs(a[k] - b[k]) < 1e-9 for k in a)
    fa, fb = E.failures(d), E.failures(shuffled)
    assert fa["l1"] == fb["l1"] and fa["l2"] == fb["l2"]
    assert sorted(o["id"] for o in fa["one_of_two"]) == sorted(o["id"] for o in fb["one_of_two"])


@given(S.chain_runs(min_size=1), S.chain_runs(min_size=1))
def test_counts_add_up_over_the_union_of_two_runs(d1, d2):
    """Metamorphic: metrics(A ∪ B) = metrics(A) + metrics(B) for every count."""
    d2 = [{**e, "id": "B" + e["id"]} for e in d2]
    a, b, ab = E.metrics(d1, {}), E.metrics(d2, {}), E.metrics(d1 + d2, {})
    for k in ab:
        if not k.startswith(_MEANS):
            assert abs(ab[k] - (a.get(k, 0) + b.get(k, 0))) < 1e-9, k
    f1, f2, f12 = E.failures(d1), E.failures(d2), E.failures(d1 + d2)
    assert f12["l1"] == f1["l1"] + f2["l1"] and f12["l2"] == f1["l2"] + f2["l2"]


@given(S.chain_runs())
def test_failures_account_for_every_failed_part(d):
    f = E.failures(d)
    l1_failed = sum(not e["l1"]["success"] for e in d)
    fell_back = sum(e["l1"]["success"] and e["l1"]["mode"] == "single-fallback" for e in d)
    assert sum(f["l1"].values()) == l1_failed + fell_back
    assert sum(f["l2"].values()) == sum(not x["success"] for e in d for x in e["l2"])
    assert "unknown" not in f["l2"] and all(c in E.classify.__globals__["CLASSES"] for c in f["l2"])
    for o in f["one_of_two"]:
        e = next(e for e in d if e["id"] == o["id"])
        assert [x["success"] for x in e["l2"]].count(True) == 1
        assert e["l2"][("first", "second").index(o["failed"])]["contract"] == o["contract"]


@given(st.lists(st.one_of(st.integers(0, 500), st.floats(0, 500, allow_nan=False)), min_size=1, max_size=5),
       st.randoms(use_true_random=False))
def test_spread_reports_mean_min_and_max(values, rnd):
    text = E.spread(values)
    if len(values) == 1:
        assert "(" not in text and float(text) == round(values[0], 2)
        return
    m = re.fullmatch(r"([\d.]+) \(([\d.e+-]+)–([\d.e+-]+)\)", text)
    assert m, text
    mean, lo, hi = map(float, m.groups())
    assert abs(mean - sum(values) / len(values)) <= 0.005 + 1e-9
    assert abs(lo - min(values)) <= 0.005 + 1e-6 * max(values) and abs(hi - max(values)) <= 0.005 + 1e-6 * max(values)
    shuffled = list(values)
    rnd.shuffle(shuffled)
    assert E.spread(shuffled).split(" ")[1] == text.split(" ")[1]   # min–max does not depend on the order


# ---------------------------------------------------------------------------
# Evaluation: compare_runs
# ---------------------------------------------------------------------------

_samples = st.lists(st.integers(0, 100), min_size=1, max_size=4)


@given(_samples, _samples, st.sampled_from(["checked (L0 OK)", "L0.5 pass", "L0.5 fail", "mean attempts"]))
def test_verdict_is_antisymmetric(xs, ys, name):
    """Metamorphic: swapping the two runs swaps better and worse and keeps the neutral verdicts."""
    a, b = CR.summarize(xs), CR.summarize(ys)
    v, w = CR.verdict(name, a, b, len(xs), len(ys)), CR.verdict(name, b, a, len(ys), len(xs))
    flip = {"**better**": "**worse**", "**worse**": "**better**"}
    assert w == flip.get(v, v)
    if v in flip:                                                   # a real difference exceeds both spreads
        assert abs(b[0] - a[0]) > max(max(xs) - min(xs), max(ys) - min(ys))
        lower_is_better = name in CR.LOWER_BETTER
        assert (v == "**better**") == ((b[0] < a[0]) if lower_is_better else (b[0] > a[0]))
    assert (v == "same") == (a[0] == b[0])


@given(_samples)
def test_fmt_shows_the_spread_only_for_repeated_runs(xs):
    mean, lo, hi = CR.summarize(xs)
    assert lo <= mean <= hi
    text = CR.fmt(mean, lo, hi, len(xs))
    assert ("(" in text) == (len(xs) > 1)
    assert abs(float(text.split(" ")[0]) - mean) <= 0.005 + 1e-9


@given(st.lists(st.fixed_dictionaries({
    "compiles": st.booleans(), "checked": st.booleans(), "attempts": st.integers(0, 6),
    "rejects_bad_example": st.sampled_from([True, False, None]),
    "l05": st.one_of(st.none(), st.fixed_dictionaries({"status": st.sampled_from(["pass", "flag", "fail"])}))}),
    max_size=12))
def test_l0_metrics_partition_the_entries(results):
    m = CR.metrics({"results": results})
    judged = sum(r["l05"] is not None for r in results)
    assert m["entries"] == len(results)
    assert m["L0.5 pass"] + m["L0.5 flag"] + m["L0.5 fail"] == judged
    assert m["negative: rejects"] + m["negative: accepts forbidden"] == sum(
        r["rejects_bad_example"] is not None for r in results)
    assert 0 <= m["compiles"] <= len(results) and 0 <= m["mean attempts"] <= 6


# ---------------------------------------------------------------------------
# Requirements graph: ordering and grouping
# ---------------------------------------------------------------------------

_names = st.lists(st.sampled_from(list("ABCDEFGHIJKL")), min_size=1, max_size=6, unique=True)


@st.composite
def weighted(draw, max_nodes: int = 6):
    nodes = draw(st.lists(st.sampled_from(list("ABCDEFGHIJKL")), min_size=1, max_size=max_nodes, unique=True))
    pairs = [(a, b) for a in nodes for b in nodes if a != b]
    chosen = draw(st.lists(st.sampled_from(pairs), max_size=12, unique=True)) if pairs else []
    return nodes, {p: draw(st.integers(1, 5)) for p in chosen}


@given(weighted(), st.randoms(use_true_random=False))
def test_order_cycle_is_an_optimal_order_whatever_order_the_nodes_come_in(gw, rnd):
    nodes, weight = gw
    order = G.order_cycle(nodes, weight)
    assert sorted(order) == sorted(nodes)
    best = min(G._back_weight(list(p), weight) for p in itertools.permutations(nodes))
    assert G._back_weight(order, weight) == best
    shuffled = list(nodes)
    rnd.shuffle(shuffled)
    assert G.order_cycle(shuffled, weight) == order


@settings(max_examples=30)
@given(st.integers(9, 12), st.data())
def test_greedy_order_of_a_large_cycle_is_still_a_permutation(n, data):
    nodes = [f"C{k:02d}" for k in range(n)]
    pairs = [(a, b) for a in nodes for b in nodes if a != b]
    weight = {p: 1 for p in data.draw(st.lists(st.sampled_from(pairs), max_size=30, unique=True))}
    order = G.order_cycle(nodes, weight)
    assert sorted(order) == nodes
    assert G._back_weight(order, weight) <= sum(weight.values())
    if not weight:
        assert order == nodes


@given(weighted(max_nodes=7))
def test_chain_order_lists_every_component_and_exactly_the_backward_edges(gw):
    nodes, weight = gw
    cg = nx.DiGraph()
    cg.add_nodes_from(sorted(nodes))
    cg.add_edges_from(weight)
    order, feedback = G.chain_order(cg, {})
    assert sorted(order) == sorted(nodes)
    pos = {c: k for k, c in enumerate(order)}
    assert feedback == sorted((a, b) for a, b in cg.edges if pos[a] > pos[b])
    if nx.is_directed_acyclic_graph(cg):
        assert feedback == []                                      # a DAG has a chain order with no feedback
    else:
        # only edges inside a strongly connected set can point backwards
        scc = {n: k for k, c in enumerate(nx.strongly_connected_components(cg)) for n in c}
        assert feedback and all(scc[a] == scc[b] for a, b in feedback)
    acyclic = nx.DiGraph((a, b) for a, b in cg.edges if (a, b) not in feedback)
    assert nx.is_directed_acyclic_graph(acyclic)                   # removing the feedback edges breaks every cycle


_entity = st.sampled_from(["account", "order", "product", "cart"])


@st.composite
def operations(draw):
    n = draw(st.integers(0, 6))
    side = st.lists(st.fixed_dictionaries({"entity": _entity, "field": S.field_name}), max_size=3)
    return [{"id": f"op{k}", "reads": draw(side), "writes": draw(side)} for k in range(n)]


@given(operations(), st.randoms(use_true_random=False))
def test_dataflow_edges_are_exactly_writer_to_reader_pairs(ops, rnd):
    edges = G.dataflow_edges(ops)
    expected = {(a["id"], b["id"]) for a in ops for b in ops if a is not b
                and {w["entity"] for w in a["writes"]} & {r["entity"] for r in b["reads"]}}
    assert set(edges) == expected
    for (a, b), reasons in edges.items():
        assert a != b and all(r["kind"] == "dataflow" and a in r["reason"] and b in r["reason"] for r in reasons)
    shuffled = list(ops)
    rnd.shuffle(shuffled)
    again = G.dataflow_edges(shuffled)
    assert set(again) == set(edges)
    assert all(len(again[k]) == len(edges[k]) for k in edges)


@settings(max_examples=40)
@given(st.integers(1, 14), st.data())
def test_split_group_partitions_the_operations(n, data):
    nodes = [f"op{k:02d}" for k in range(n)]
    pairs = [(a, b) for a, b in itertools.combinations(nodes, 2)]
    g = nx.Graph()
    g.add_nodes_from(nodes)
    for a, b in (data.draw(st.lists(st.sampled_from(pairs), max_size=25, unique=True)) if pairs else []):
        g.add_edge(a, b, weight=data.draw(st.integers(1, 3)))
    comms, how, q = G.split_group(g)
    assert sorted(m for c in comms for m in c) == nodes            # every operation in exactly one component
    assert all(c == sorted(c) and c for c in comms)
    assert how in ("connected", "louvain", "connected (no clear communities)")
    if how.startswith("connected"):
        assert comms == [nodes] and n <= G.MAX_COMPONENT_OPS
    if n < G.MIN_SPLIT_OPS:
        assert how == "connected"
    assert G.split_group(g) == (comms, how, q)                     # fixed Louvain seed: the same split again


@given(st.lists(st.sampled_from(["product", "To", "Add", "ID", "item", "URL", "cart"]), min_size=1, max_size=4))
def test_split_words_reads_camel_snake_and_spaced_names_alike(words):
    assume(not any(a.isupper() and b.isupper() for a, b in zip(words, words[1:])))   # `IDURL` is one acronym
    lower = [w.lower() for w in words]
    camel = words[0].lower() + "".join(w if w.isupper() else w.capitalize() for w in words[1:])
    assert G.split_words("_".join(words)) == lower
    assert G.split_words(" ".join(words)) == lower
    if not any(a.isupper() and b[:1].isupper() for a, b in zip(words, words[1:])):
        assert G.split_words(camel) == lower


@given(st.text(alphabet="abcXYZ 019_-()", max_size=20))
def test_type_names_never_returns_a_builtin(t):
    names = G.type_names(f"List (Option {t})")
    assert not set(names) & {"List", "Option", "Nat", "String", "Bool"}
    assert all(n[0].isupper() for n in names)
