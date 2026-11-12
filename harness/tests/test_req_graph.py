"""req_graph: determinism, write → read edges, cycles (listed, then merged), unmapped fields,
use-case precondition links. Synthetic SRS and L0 specs; needs spaCy's en_core_web_sm."""
import json
import os
import subprocess
import sys
import unittest
from pathlib import Path

HARNESS = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(HARNESS))

try:
    import spacy
    spacy.load("en_core_web_sm")
    HAVE_SPACY = True
except Exception:  # pragma: no cover
    HAVE_SPACY = False

DOMAIN = """
structure Shelf where
  label : String
  deriving DecidableEq, Repr
structure Book where
  title : String
  shelfLabel : String
  deriving DecidableEq, Repr
structure Loan where
  title : String
  member : String
  deriving DecidableEq, Repr
"""


def spec(io_in: str, io_out: str, post: str = "True") -> str:
    return (f"structure Input where\n{io_in}\n  deriving DecidableEq, Repr\n\n"
            f"structure Output where\n{io_out}\n  deriving DecidableEq, Repr\n\n"
            f"def Spec : Contract Input Output where\n  pre := fun _ => True\n  post := fun i o => {post}\n")


def result(rid: str, code: str, kind: str = "requirement", text: str = "") -> dict:
    return {"id": rid, "kind": kind, "requirement_text": text, "lean_predicate": code,
            "compiles": True, "checked": True}


def doc(use_cases=None) -> dict:
    return {"source": {"file": "toy.xml"}, "glossary": [{"term": "Book", "meaning": "also called volume"}],
            "requirements": [], "data_dictionary": [], "use_cases": use_cases or []}


@unittest.skipUnless(HAVE_SPACY, "spaCy en_core_web_sm not installed")
class GraphTests(unittest.TestCase):
    def build(self, results, use_cases=None, synonyms=None):
        import req_graph
        return req_graph.build_graph(doc(use_cases), {"results": results}, DOMAIN, synonyms or {})

    def test_write_read_edge_with_reason(self):
        g = self.build([
            result("A-shelve", spec("  title : String", "  books : List Book")),
            result("B-lend", spec("  books : List Book", "  loan : Loan")),
        ])
        edges = {(e["src"], e["dst"]): e for e in g["edges"]}
        self.assertIn(("A-shelve", "B-lend"), edges)
        r = edges[("A-shelve", "B-lend")]["reasons"][0]
        self.assertEqual((r["kind"], r["entity"]), ("dataflow", "book"))
        self.assertIn("`o.books`", r["reason"])
        self.assertNotIn(("B-lend", "A-shelve"), edges)

    def test_copied_output_is_a_read_not_a_write(self):
        g = self.build([result("A", spec("  books : List Book", "  books : List Book", "o.books = i.books"))])
        op = g["operations"][0]
        self.assertEqual(op["entities_written"], [])
        self.assertTrue(op["reads"][-1].get("copied"))

    def test_bool_result_is_not_a_write(self):
        g = self.build([result("A", spec("  title : String", "  book : Bool"))])
        self.assertEqual(g["operations"][0]["entities_written"], [])
        self.assertEqual(g["operations"][0]["results"][0]["field"], "book")

    def test_unmapped_field_reported(self):
        g = self.build([result("A", spec("  zorblax : Nat", "  books : List Book"))])
        self.assertIn({"operation": "A", "side": "input", "field": "zorblax", "type": "Nat"},
                      g["unmapped_fields"])
        self.assertLess(g["metrics"]["pct_fields_mapped"], 100)

    def test_mapping_by_type_and_synonym(self):
        g = self.build([result("A", spec("  stuff : List Book", "  volume : Book"))],
                       synonyms={"tome": "book"})
        op = g["operations"][0]
        self.assertEqual(op["reads"][0]["rule"], "type")
        self.assertEqual(op["writes"][0]["via"], "synonym")  # glossary: Book "also called volume"

    def split_each(self, results, cycles="break", **kw):
        """Build with every operation in its own component (Louvain replaced)."""
        import req_graph
        old = (req_graph.MAX_COMPONENT_OPS, req_graph._louvain_split, req_graph.CYCLE_MODE)
        req_graph.MAX_COMPONENT_OPS = 1
        req_graph._louvain_split = lambda g: [[n] for n in sorted(g.nodes)]
        req_graph.CYCLE_MODE = cycles
        try:
            return self.build(results, **kw)
        finally:
            req_graph.MAX_COMPONENT_OPS, req_graph._louvain_split, req_graph.CYCLE_MODE = old

    def test_louvain_split_respects_size(self):
        import networkx as nx
        import req_graph
        g = nx.Graph()
        for side in "ab":  # two 4-cliques joined by one edge
            ns = [f"{side}{k}" for k in range(4)]
            g.add_edges_from((x, y, {"weight": 3}) for i, x in enumerate(ns) for y in ns[i + 1:])
        g.add_edge("a0", "b0", weight=1)
        old = req_graph.MAX_COMPONENT_OPS
        req_graph.MAX_COMPONENT_OPS = 4
        try:
            parts = req_graph._louvain_split(g)
        finally:
            req_graph.MAX_COMPONENT_OPS = old
        self.assertEqual(sorted(parts), [["a0", "a1", "a2", "a3"], ["b0", "b1", "b2", "b3"]])

    CYCLE = [("A", "  loan : Loan", "  books : List Book"), ("B", "  books : List Book", "  loan : Loan"),
             ("C", "  loan : Loan", "  shelf : Shelf")]

    def test_cycle_broken_components_kept(self):
        """Default: A ⇄ B is a cycle; both stay components, the order has one backward edge."""
        g = self.split_each([result(i, spec(a, b)) for i, a, b in self.CYCLE])
        grp = g["groups"][0]
        self.assertFalse(grp["acyclic"])
        self.assertEqual(grp["cycles_resolved"], "break")
        self.assertEqual(len(grp["components"]), 3)
        self.assertEqual(grp["merged_cycles"], [])
        comp = {o["id"]: o["component"] for o in g["operations"]}
        self.assertEqual(len(set(comp.values())), 3)
        self.assertEqual(len(grp["feedback_edges"]), 1)
        pos = {c: k for k, c in enumerate(grp["order"])}
        fb = grp["feedback_edges"][0]
        self.assertGreater(pos[fb["src"]], pos[fb["dst"]])
        # every other component edge points forwards
        back = [(e["src"], e["dst"]) for e in grp["component_edges"] if pos[e["src"]] > pos[e["dst"]]]
        self.assertEqual(back, [(fb["src"], fb["dst"])])
        self.assertLess(pos[comp["B"]], pos[comp["C"]])  # B writes the loan C reads
        self.assertEqual(g["metrics"]["feedback_edges"], 1)

    def test_order_cycle_minimises_backward_weight(self):
        import req_graph
        w = {("a", "b"): 5, ("b", "c"): 5, ("c", "a"): 1}
        self.assertEqual(req_graph.order_cycle(["c", "b", "a"], w), ["a", "b", "c"])
        old = req_graph.EXACT_ORDER_MAX
        req_graph.EXACT_ORDER_MAX = 0   # the greedy path agrees here
        try:
            self.assertEqual(req_graph.order_cycle(["c", "b", "a"], w), ["a", "b", "c"])
        finally:
            req_graph.EXACT_ORDER_MAX = old

    def test_state_entity_from_the_specs_alone(self):
        """`signedIn` is in no document: one spec writes it, another reads it → an entity, an
        edge and one group, without Domain.lean or a synonyms file."""
        import req_graph
        res = [result("login", spec("  password : String", "  signedIn : Bool")),
               result("order", spec("  signedIn : Bool", "  placed : Bool")),
               result("other", spec("  zorblax : Nat", "  done : Bool"))]
        g = req_graph.build_graph(doc(), {"results": res}, None, {})
        self.assertEqual(g["metrics"]["state_entities"], ["sign"])
        ops = {o["id"]: o for o in g["operations"]}
        self.assertEqual(ops["login"]["entities_written"], ["sign"])     # a Bool, but it is state
        self.assertEqual(ops["order"]["entities_read"], ["sign"])
        self.assertIn(("login", "order"), {(e["src"], e["dst"]) for e in g["edges"]})
        self.assertEqual(ops["other"]["entities_written"], [])            # `done` is only ever a result
        self.assertIn("other", g["isolated_operations"])
        self.assertEqual(g["metrics"]["entities_used_by_source"], {"shared field": 1})

    def test_helper_structures_are_entities_without_a_domain_file(self):
        import req_graph
        code = ("structure Ticket where\n  seat : Nat\n  deriving DecidableEq, Repr\n\n"
                + spec("  tickets : List Ticket", "  tickets : List Ticket"))
        g = req_graph.build_graph(doc(), {"results": [result("A", code), result("B", code)]}, None, {})
        self.assertEqual(g["operations"][0]["reads"][0]["entity"], "ticket")
        self.assertEqual(g["metrics"]["pct_fields_mapped"], 100.0)
        self.assertEqual(g["metrics"]["groups"], 1)

    def test_small_group_split_only_with_clear_communities(self):
        import networkx as nx
        import req_graph
        two = nx.Graph()
        for side in "ab":  # two triangles joined by one weak edge: real communities
            ns = [f"{side}{k}" for k in range(3)]
            two.add_edges_from((x, y, {"weight": 3}) for i, x in enumerate(ns) for y in ns[i + 1:])
        two.add_edge("a0", "b0", weight=1)
        comms, how, q = req_graph.split_group(two)
        self.assertEqual((sorted(comms), how), ([["a0", "a1", "a2"], ["b0", "b1", "b2"]], "louvain"))
        self.assertGreaterEqual(q, req_graph.MIN_MODULARITY)
        clique = nx.complete_graph(["a", "b", "c", "d", "e"])
        nx.set_edge_attributes(clique, 1, "weight")
        comms, how, _ = req_graph.split_group(clique)   # no structure: one component
        self.assertEqual(len(comms), 1)
        self.assertTrue(how.startswith("connected"))
        tiny = nx.path_graph(["a", "b", "c"])
        self.assertEqual(req_graph.split_group(tiny)[1], "connected")   # below MIN_SPLIT_OPS

    def test_cycle_listed_and_merged(self):
        """CF_GRAPH_CYCLES=merge (the v1 behaviour)."""
        g = self.split_each([result(i, spec(a, b)) for i, a, b in self.CYCLE], cycles="merge")
        grp = g["groups"][0]
        self.assertFalse(grp["acyclic"])
        self.assertEqual(len(grp["cycles"]), 1)
        self.assertEqual(len(grp["components"]), 2)  # A and B merged; C stays apart
        comp = {o["id"]: o["component"] for o in g["operations"]}
        self.assertEqual(comp["A"], comp["B"])
        self.assertEqual(grp["order"], [comp["A"], comp["C"]])
        self.assertEqual(g["metrics"]["merged_component_sets"], 1)

    def test_acyclic_split_gives_an_order(self):
        g = self.split_each([
            result("C", spec("  books : List Book", "  loan : Loan")),
            result("A", spec("  title : String", "  shelf : Shelf")),
            result("B", spec("  shelf : Shelf", "  books : List Book")),
        ])
        grp = g["groups"][0]
        self.assertTrue(grp["acyclic"])
        comp = {o["id"]: o["component"] for o in g["operations"]}
        self.assertEqual(grp["order"], [comp["A"], comp["B"], comp["C"]])

    def test_precondition_link(self):
        ucs = [{"id": "UC-login", "name": "Login", "actors": ["Member"], "preconditions": [],
                "postconditions": ["The Member is logged into the system."]},
               {"id": "UC-borrow", "name": "Borrow", "actors": ["Member"],
                "preconditions": ["Member must be logged-in on the system."], "postconditions": []},
               {"id": "UC-logout", "name": "Logout", "actors": ["Member"], "preconditions": [],
                "postconditions": ["The Member is logged out of the system."]}]
        res = [result(u["id"], spec("  title : String", "  ok : Bool"), "use_case") for u in ucs]
        g = self.build(res, use_cases=ucs)
        links = {(e["src"], e["dst"]) for e in g["edges"]
                 if any(r["kind"] == "precondition" for r in e["reasons"])}
        self.assertEqual(links, {("UC-login", "UC-borrow")})  # `log in` ≠ `log out`

    def test_same_bytes_across_hash_seeds(self):
        """Same inputs → same graph.json bytes, in fresh interpreters with different hash seeds."""
        script = (
            "import json,sys; sys.path[:0] = [%r, %r]\n"
            "import req_graph, test_req_graph as t\n"
            "res=[t.result('A', t.spec('  title : String', '  books : List Book')),"
            " t.result('B', t.spec('  books : List Book', '  loan : Loan')),"
            " t.result('C', t.spec('  loan : Loan', '  shelf : Shelf'))]\n"
            "req_graph.MAX_COMPONENT_OPS = 1\n"
            "print(req_graph.to_json(req_graph.build_graph(t.doc(), {'results': res}, t.DOMAIN, {})))\n"
        ) % (str(HARNESS), str(HARNESS / "tests"))
        outs = set()
        for seed in ("1", "2", "3"):
            env = {**os.environ, "PYTHONHASHSEED": seed}
            outs.add(subprocess.run([sys.executable, "-c", script], cwd=HARNESS, env=env,
                                    capture_output=True, text=True, check=True).stdout)
        self.assertEqual(len(outs), 1)
        json.loads(outs.pop())


if __name__ == "__main__":
    unittest.main()
