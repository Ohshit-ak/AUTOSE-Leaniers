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

    def split_each(self, results, **kw):
        """Build with every operation in its own component (Louvain replaced)."""
        import req_graph
        old = (req_graph.MAX_COMPONENT_OPS, req_graph._louvain_split)
        req_graph.MAX_COMPONENT_OPS = 1
        req_graph._louvain_split = lambda g: [[n] for n in sorted(g.nodes)]
        try:
            return self.build(results, **kw)
        finally:
            req_graph.MAX_COMPONENT_OPS, req_graph._louvain_split = old

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

    def test_cycle_listed_and_merged(self):
        g = self.split_each([
            result("A", spec("  loan : Loan", "  books : List Book")),
            result("B", spec("  books : List Book", "  loan : Loan")),
            result("C", spec("  loan : Loan", "  shelf : Shelf")),
        ])
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
