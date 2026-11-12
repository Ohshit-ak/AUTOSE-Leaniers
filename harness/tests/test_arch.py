"""L1 tools (agents/arch_tools.py) on a toy shop (not gamma j): every tool, a hand-written
correct 2-component architecture that passes everything, and the cases the harness must
reject. Tests that run Lean are skipped if `lake` is missing."""
import shutil
import sys
import unittest
from pathlib import Path

HARNESS = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(HARNESS))
HAS_LEAN = shutil.which("lake") is not None

L0 = {
    "OP-restock": """structure Input where
  stock : Nat
  amount : Nat
  deriving DecidableEq, Repr

structure Output where
  stock : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre := fun i => 0 < i.amount
  post := fun i o => o.stock = i.stock + i.amount

example : Spec.pre { stock := 3, amount := 2 } ∧ Spec.post { stock := 3, amount := 2 } { stock := 5 } := by
  unfold Spec; decide
""",
    "OP-sell": """structure Input where
  stock : Nat
  deriving DecidableEq, Repr

structure Output where
  stock : Nat
  sold : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre := fun i => 0 < i.stock
  post := fun i o => o.stock + 1 = i.stock ∧ o.sold = true

example : Spec.pre { stock := 4 } ∧ Spec.post { stock := 4 } { stock := 3, sold := true } := by
  unfold Spec; decide
""",
    "OP-audit": """structure Input where
  stock : Nat
  deriving DecidableEq, Repr

structure Output where
  ok : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre := fun _ => True
  post := fun i o => (o.ok = true ↔ i.stock ≤ 100)

example : Spec.pre { stock := 7 } ∧ Spec.post { stock := 7 } { ok := true } := by
  unfold Spec; decide
""",
}

DOMAIN = "structure Item where\n  stock : Nat\n  deriving DecidableEq, Repr\n"

GRAPH = {
    "groups": [{"id": "ShopSys", "operations": sorted(L0), "order": ["Stock", "Audit"], "split": "louvain",
                "component_edges": [{"src": "Stock", "dst": "Audit",
                                     "reasons": ["OP-sell → OP-audit: OP-sell writes item"]}],
                "cycles": [], "merged_cycles": []}],
    "components": [
        {"id": "Stock", "group": "ShopSys", "operations": ["OP-restock", "OP-sell"],
         "entities_read": ["item"], "entities_written": ["item"]},
        {"id": "Audit", "group": "ShopSys", "operations": ["OP-audit"],
         "entities_read": ["item"], "entities_written": []},
    ],
}

STOCK = """def Stock_pre_op_restock (i : L0_op_restock.Input) : Prop := 0 < i.amount
def Stock_post_op_restock (i : L0_op_restock.Input) (o : L0_op_restock.Output) : Prop :=
  o.stock = i.stock + i.amount
def Stock_pre_op_sell (i : L0_op_sell.Input) : Prop := 0 < i.stock
def Stock_post_op_sell (i : L0_op_sell.Input) (o : L0_op_sell.Output) : Prop :=
  o.stock + 1 = i.stock ∧ o.sold = true"""

AUDIT = """def Audit_pre_op_audit (_ : L0_op_audit.Input) : Prop := True
def Audit_post_op_audit (i : L0_op_audit.Input) (o : L0_op_audit.Output) : Prop :=
  (o.ok = true ↔ i.stock ≤ 100)"""


def session():
    from agents.arch_tools import ArchSession
    return ArchSession(GRAPH, "ShopSys", dict(L0), DOMAIN,
                       l0_texts={"OP-sell": "The system shall sell one unit."})


class ReadTools(unittest.TestCase):
    def test_summary_component_spec_domain(self):
        s = session()
        self.assertIn("Stock: 2 operations", s.get_graph_summary())
        self.assertIn("Audit", s.get_graph_summary())
        comp = s.get_component("Stock")
        self.assertIn("def Stock_pre_op_sell (i : L0_op_sell.Input) : Prop", comp)
        self.assertIn("next: Audit", comp)
        spec = s.get_l0_spec("OP-sell")
        self.assertIn("sell one unit", spec)
        self.assertIn("namespace L0_op_sell", spec)
        self.assertNotIn("example", spec)
        self.assertIn("structure Item", s.get_domain_types())

    def test_lookup_name(self):
        self.assertIn("`List.length`", session().lookup_name("List.lenght"))

    def test_decomposition_rules(self):
        from agents.arch_tools import check_decomposition
        ops = sorted(L0)
        self.assertEqual(check_decomposition([{"id": "A", "operations": ops[:1]},
                                              {"id": "B", "operations": ops[1:]}], ops), [])
        single = check_decomposition([{"id": "All", "operations": ops}], ops)
        self.assertTrue(any("single component" in p for p in single))
        self.assertTrue(check_decomposition([{"id": "A", "operations": ops[:1]},
                                             {"id": "B", "operations": ops[:2]}], ops))  # overlap + missing
        self.assertTrue(check_decomposition([{"id": "bad name", "operations": ops[:1]},
                                             {"id": "B", "operations": ops[1:]}], ops))

    def test_code_rules(self):
        s = session()
        self.assertTrue(any("sorry" in p for p in s.code_problems("Stock", "def Stock_x : Nat := by sorry")))
        self.assertTrue(any("named `Stock_" in p for p in s.code_problems("Stock", "def helper : Nat := 1")))
        self.assertTrue(any("L0_" in p for p in s.code_problems(
            "Stock", "def Stock_pre_op_sell (i : L0_op_sell.Input) : Prop := L0_op_sell.Spec.pre i")))
        self.assertTrue(any("structure" in p for p in s.code_problems("Stock", "structure Foo where\n  x : Nat")))


@unittest.skipUnless(HAS_LEAN, "lake not installed")
class LeanTools(unittest.TestCase):
    def test_check_lean(self):
        s = session()
        self.assertEqual(s.check_lean("example : L0_op_sell.Input := { stock := 1 }"), "ok")
        self.assertIn("Lean errors", s.check_lean("example : Nat := \"x\""))

    def test_correct_toy_architecture_passes_everything(self):
        s = session()
        self.assertTrue(s.check_contract("Stock", STOCK)["ok"])
        self.assertTrue(s.check_contract("Audit", AUDIT)["ok"])
        for comp, op in (("Stock", "OP-restock"), ("Stock", "OP-sell"), ("Audit", "OP-audit")):
            self.assertTrue(s.check_trace(comp, op)["ok"], (comp, op))
        self.assertTrue(s.check_po1("Stock", "Audit")["ok"])
        self.assertTrue(s.check_po2()["ok"])
        final = s.submit_architecture()
        self.assertTrue(final["ok"], final["text"])
        self.assertTrue(final["arch_compiles"])
        self.assertIn("theorem system_sound_ShopSys", final["arch"])
        self.assertIn("theorem po1_Stock_Audit", final["arch"])

    def test_vacuous_contract_rejected(self):
        s = session()
        vac = AUDIT.replace("(o.ok = true ↔ i.stock ≤ 100)", "True")
        r = s.check_contract("Audit", vac)
        self.assertFalse(r["ok"])
        self.assertTrue(r["ops"]["OP-audit"]["vacuous"])

    def test_contract_rejecting_l0_example_flagged(self):
        s = session()
        r = s.check_contract("Stock", STOCK.replace("0 < i.stock", "10 < i.stock"))
        self.assertFalse(r["ok"])
        self.assertTrue(r["ops"]["OP-sell"]["pre_false"])

    def test_changed_domain_rejected(self):
        s = session()
        s.check_contract("Stock", STOCK)
        s.check_contract("Audit", AUDIT)
        s.domain_code = DOMAIN + "\nstructure Sneaky where\n  x : Nat\n"
        final = s.submit_architecture()
        self.assertFalse(final["ok"])
        self.assertTrue(any("locked context changed" in p for p in final["problems"]))

    def test_unprovable_po1_rejected(self):
        """Audit assumes more than the L0 spec (stock < 5): its trace `pre` fails, so PO1
        Stock → Audit cannot be proved and the architecture is rejected (degrading off)."""
        s = session()
        s.degrade_failed = False
        s.check_contract("Stock", STOCK)
        s.check_contract("Audit", AUDIT.replace(": Prop := True", ": Prop := i.stock < 5").replace("(_ :", "(i :"))
        self.assertFalse(s.check_po1("Stock", "Audit")["ok"])
        final = s.submit_architecture()
        self.assertFalse(final["ok"])
        self.assertFalse(final["proved"]["po1:Stock:Audit"])
        self.assertTrue(final["arch_compiles"])  # failed obligations become comments
        self.assertIn("-- NOT PROVED: theorem po1_Stock_Audit", final["arch"])

    def test_single_component_rejected_in_no_graph_mode(self):
        from agents.arch_tools import ArchSession
        s = ArchSession(GRAPH, "ShopSys", dict(L0), DOMAIN,
                        components=[{"id": "All", "operations": sorted(L0)}])
        s.require_split = True
        s.check_contract("All", STOCK.replace("Stock_", "All_") + "\n" + AUDIT.replace("Audit_", "All_"))
        final = s.submit_architecture()
        self.assertFalse(final["ok"])
        self.assertTrue(any("single component" in p for p in final["problems"]))

    def test_failing_operation_is_degraded_not_blocking(self):
        """Same bad Audit contract with degrading on (the default): OP-audit keeps its L0
        conditions, every obligation of the group is proved, and the verdict says so."""
        s = session()
        self.assertTrue(s.degrade_failed)
        s.check_contract("Stock", STOCK)
        s.check_contract("Audit", AUDIT.replace(": Prop := True", ": Prop := i.stock < 5").replace("(_ :", "(i :"))
        final = s.submit_architecture()
        self.assertTrue(final["ok"], final["text"])
        self.assertEqual(final["verdict"], "accepted-degraded")
        self.assertEqual(list(final["degraded"]), ["OP-audit"])
        self.assertEqual(final["degraded"]["OP-audit"], "`pre` is false on the L0 example")
        self.assertTrue(all(final["proved"].values()))
        self.assertTrue(final["proved"]["po2"])
        self.assertTrue(final["arch_compiles"])
        self.assertIn("harness fallback for OP-audit", final["arch"])
        self.assertIn("def Audit_pre_op_audit (i : L0_op_audit.Input) : Prop := L0_op_audit.Spec.pre i", final["arch"])
        self.assertNotIn("i.stock < 5", final["arch"])           # the model's definitions are gone
        self.assertIn("def Stock_post_op_sell", final["arch"])    # the other operations keep theirs
        self.assertEqual(s.results["trace_pre:Audit:OP-audit"]["by"], "fallback")

    def test_missing_operation_is_degraded(self):
        s = session()
        s.check_contract("Stock", STOCK.split("def Stock_pre_op_sell")[0])  # restock only
        self.assertEqual(s.fill_missing("Stock"), ["OP-sell"])
        s.check_contract("Audit", AUDIT)
        final = s.submit_architecture()
        self.assertEqual(final["verdict"], "accepted-degraded")
        self.assertEqual(final["degraded"], {"OP-sell": "no valid contract from the model"})
        self.assertEqual(s.placeholders, ["OP-sell"])

    def test_a_correct_architecture_is_not_degraded(self):
        s = session()
        s.check_contract("Stock", STOCK)
        s.check_contract("Audit", AUDIT)
        final = s.submit_architecture()
        self.assertEqual(final["verdict"], "accepted")
        self.assertEqual(final["degraded"], {})

    def test_placeholders_compile_and_are_reported(self):
        s = session()
        s.degrade_failed = False
        s.check_contract("Stock", STOCK.split("def Stock_pre_op_sell")[0])  # restock only
        self.assertEqual(s.fill_missing("Stock"), ["OP-sell"])
        s.check_contract("Audit", AUDIT)
        final = s.submit_architecture()
        self.assertFalse(final["ok"])
        self.assertTrue(final["arch_compiles"])
        self.assertFalse(final["proved"]["trace_pre:Stock:OP-sell"])


if __name__ == "__main__":
    unittest.main()
