"""Unit tests for L2 deterministic Lean code generator (harness/code_lean.py)."""
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

HARNESS = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(HARNESS))

import code_lean
import arch_lean

HAS_LEAN = shutil.which("lake") is not None


class TestCodeLeanNaming(unittest.TestCase):
    def test_naming(self):
        self.assertEqual(code_lean.impl_op_name("Stock", "OP-restock"), "Stock_impl_op_restock")
        self.assertEqual(code_lean.impl_op_name("Stock", "OP-sell"), "Stock_impl_op_sell")
        self.assertEqual(code_lean.impl_op_name("Audit", "OP-audit"), "Audit_impl_op_audit")

        self.assertEqual(code_lean.impl_op_ok_name("Stock", "OP-restock"), "Stock_impl_op_restock_ok")
        self.assertEqual(code_lean.impl_op_ok_name("Stock", "OP-sell"), "Stock_impl_op_sell_ok")

        self.assertEqual(code_lean.po3_name("Stock"), "StockImpl_ok")
        self.assertEqual(code_lean.po3_name("Audit"), "AuditImpl_ok")

        self.assertEqual(code_lean.system_impl_name("ShopSys"), "ShopSysSystemImpl")

    def test_signatures_and_statements(self):
        sig = code_lean.impl_op_sig("Stock", "OP-restock")
        self.assertEqual(sig, "def Stock_impl_op_restock (i : L0_op_restock.Input) : L0_op_restock.Output := …")

        stmt = code_lean.impl_op_ok_statement("Stock", "OP-restock")
        expected_stmt = (
            "theorem Stock_impl_op_restock_ok : ∀ i : L0_op_restock.Input, "
            "Stock_pre_op_restock i → Stock_post_op_restock i (Stock_impl_op_restock i)"
        )
        self.assertEqual(stmt, expected_stmt)

        po3_stmt = code_lean.po3_statement("Stock")
        self.assertEqual(po3_stmt, "theorem StockImpl_ok : StockContract.Satisfies StockImpl")

        # impl_signatures sorts by slug
        sigs = code_lean.impl_signatures("Stock", ["OP-sell", "OP-restock"])
        expected_sigs = (
            "def Stock_impl_op_restock (i : L0_op_restock.Input) : L0_op_restock.Output := …\n"
            "def Stock_impl_op_sell (i : L0_op_sell.Input) : L0_op_sell.Output := …"
        )
        self.assertEqual(sigs, expected_sigs)


class TestComponentImplDef(unittest.TestCase):
    def test_component_impl_def_stock(self):
        # Stock owns OP-sell and OP-restock (unsorted input should be sorted by slug)
        res = code_lean.component_impl_def("ShopSys", "Stock", ["OP-sell", "OP-restock"], ["OP-restock", "OP-sell", "OP-audit"])
        expected = (
            "/-- Implementation of component Stock: handles owned operations, passes others unchanged. -/\n"
            "def StockImpl (m : ShopSysMsg) : ShopSysMsg :=\n"
            "  match m with\n"
            "  | .req_op_restock i => .res_op_restock (Stock_impl_op_restock i)\n"
            "  | .req_op_sell i => .res_op_sell (Stock_impl_op_sell i)\n"
            "  | m => m"
        )
        self.assertEqual(res, expected)

    def test_component_impl_def_audit(self):
        res = code_lean.component_impl_def("ShopSys", "Audit", ["OP-audit"], ["OP-restock", "OP-sell", "OP-audit"])
        expected = (
            "/-- Implementation of component Audit: handles owned operations, passes others unchanged. -/\n"
            "def AuditImpl (m : ShopSysMsg) : ShopSysMsg :=\n"
            "  match m with\n"
            "  | .req_op_audit i => .res_op_audit (Audit_impl_op_audit i)\n"
            "  | m => m"
        )
        self.assertEqual(res, expected)

    def test_component_impl_def_no_owned(self):
        res = code_lean.component_impl_def("ShopSys", "PassThrough", [], ["OP-restock"])
        expected = (
            "/-- Implementation of component PassThrough: handles owned operations, passes others unchanged. -/\n"
            "def PassThroughImpl (m : ShopSysMsg) : ShopSysMsg :=\n"
            "  match m with\n"
            "  | m => m"
        )
        self.assertEqual(res, expected)


class TestAutoPo3Proof(unittest.TestCase):
    def test_auto_po3_proof_stock(self):
        all_ops = ["OP-restock", "OP-sell", "OP-audit"]
        proof = code_lean.auto_po3_proof("ShopSys", "Stock", ["OP-restock", "OP-sell"], all_ops)
        expected = (
            "by\n"
            "  intro m hpre\n"
            "  cases m with\n"
            "  | req_op_restock i =>\n"
            "    exact ⟨Stock_impl_op_restock i, rfl, Stock_impl_op_restock_ok i hpre⟩\n"
            "  | req_op_sell i =>\n"
            "    exact ⟨Stock_impl_op_sell i, rfl, Stock_impl_op_sell_ok i hpre⟩\n"
            "  | req_op_audit i => rfl\n"
            "  | res_op_audit o => rfl\n"
            "  | res_op_restock o => rfl\n"
            "  | res_op_sell o => rfl"
        )
        self.assertEqual(proof, expected)

    def test_auto_po3_proof_audit(self):
        all_ops = ["OP-restock", "OP-sell", "OP-audit"]
        proof = code_lean.auto_po3_proof("ShopSys", "Audit", ["OP-audit"], all_ops)
        expected = (
            "by\n"
            "  intro m hpre\n"
            "  cases m with\n"
            "  | req_op_audit i =>\n"
            "    exact ⟨Audit_impl_op_audit i, rfl, Audit_impl_op_audit_ok i hpre⟩\n"
            "  | req_op_restock i => rfl\n"
            "  | req_op_sell i => rfl\n"
            "  | res_op_audit o => rfl\n"
            "  | res_op_restock o => rfl\n"
            "  | res_op_sell o => rfl"
        )
        self.assertEqual(proof, expected)


class TestSystemImplDef(unittest.TestCase):
    def test_system_impl_def_single(self):
        res = code_lean.system_impl_def("ShopSys", ["Stock"])
        self.assertEqual(res, "def ShopSysSystemImpl : ShopSysMsg → ShopSysMsg := StockImpl")

    def test_system_impl_def_two(self):
        res = code_lean.system_impl_def("ShopSys", ["Stock", "Audit"])
        self.assertEqual(res, "def ShopSysSystemImpl : ShopSysMsg → ShopSysMsg := AuditImpl ∘ StockImpl")

    def test_system_impl_def_three(self):
        res = code_lean.system_impl_def("ShopSys", ["CompA", "CompB", "CompC"])
        self.assertEqual(res, "def ShopSysSystemImpl : ShopSysMsg → ShopSysMsg := CompCImpl ∘ (CompBImpl ∘ CompAImpl)")

    def test_system_impl_def_empty_raises(self):
        with self.assertRaises(ValueError):
            code_lean.system_impl_def("ShopSys", [])


class TestSystemSoundInstantiation(unittest.TestCase):
    def test_system_sound_instantiation_single(self):
        res = code_lean.system_sound_instantiation("ShopSys", ["Stock"])
        expected = (
            "theorem system_sound_ShopSys_inst : ShopSysSystemSpec.Satisfies ShopSysSystemImpl :=\n"
            "  system_sound_ShopSys StockImpl_ok"
        )
        self.assertEqual(res, expected)

    def test_system_sound_instantiation_two(self):
        res = code_lean.system_sound_instantiation("ShopSys", ["Stock", "Audit"])
        expected = (
            "theorem system_sound_ShopSys_inst : ShopSysSystemSpec.Satisfies ShopSysSystemImpl :=\n"
            "  system_sound_ShopSys StockImpl_ok AuditImpl_ok"
        )
        self.assertEqual(res, expected)

    def test_system_sound_instantiation_empty_raises(self):
        with self.assertRaises(ValueError):
            code_lean.system_sound_instantiation("ShopSys", [])


@unittest.skipUnless(HAS_LEAN, "lake not installed")
class TestLeanEndToEnd(unittest.TestCase):
    def test_lean_typecheck_toy_shop(self):
        from tests.test_arch import L0, DOMAIN, STOCK, AUDIT

        text = """import ContractForge.Contract
import ContractForge.Chain
import ContractForge.Soundness
open ContractForge

"""
        text += DOMAIN + "\n"
        text += arch_lean.locked_context("ShopSys", L0) + "\n\n"
        text += STOCK + "\n\n"
        text += AUDIT + "\n\n"
        text += arch_lean.contract_def("ShopSys", "Stock", ["OP-restock", "OP-sell"], list(L0)) + "\n\n"
        text += arch_lean.contract_def("ShopSys", "Audit", ["OP-audit"], list(L0)) + "\n\n"

        for comp, op in [("Stock", "OP-restock"), ("Stock", "OP-sell"), ("Audit", "OP-audit")]:
            stmt = arch_lean.trace_statements(comp, op)
            s = arch_lean.slug(op)
            text += f"{stmt['pre']} := by unfold {arch_lean.pre_name(comp, op)} L0_{s}.Spec; intro i h; exact h\n\n"
            text += f"{stmt['post']} := by unfold {arch_lean.post_name(comp, op)} L0_{s}.Spec; intro i o h1 h2; exact h2\n\n"

        owner = {"OP-restock": "Stock", "OP-sell": "Stock", "OP-audit": "Audit"}
        text += arch_lean.po1_statement("Stock", "Audit") + " := " + arch_lean.auto_po1_proof("ShopSys", "Stock", "Audit", owner, list(L0)) + "\n\n"
        text += arch_lean.po2_statement("ShopSys", ["Stock", "Audit"]) + " := " + arch_lean.auto_po2_proof("ShopSys", ["Stock", "Audit"], owner, list(L0)) + "\n\n"
        text += arch_lean.system_sound_theorem("ShopSys", ["Stock", "Audit"]) + "\n\n"

        # L2 implementations
        text += """def Stock_impl_op_restock (i : L0_op_restock.Input) : L0_op_restock.Output :=
  { stock := i.stock + i.amount }

theorem Stock_impl_op_restock_ok : ∀ i : L0_op_restock.Input, Stock_pre_op_restock i → Stock_post_op_restock i (Stock_impl_op_restock i) := by
  intro i hpre
  unfold Stock_post_op_restock Stock_impl_op_restock
  rfl

def Stock_impl_op_sell (i : L0_op_sell.Input) : L0_op_sell.Output :=
  { stock := i.stock - 1, sold := true }

theorem Stock_impl_op_sell_ok : ∀ i : L0_op_sell.Input, Stock_pre_op_sell i → Stock_post_op_sell i (Stock_impl_op_sell i) := by
  intro i hpre
  dsimp [Stock_post_op_sell, Stock_impl_op_sell, Stock_pre_op_sell] at *
  refine ⟨by omega, rfl⟩
"""
        text += code_lean.component_impl_def("ShopSys", "Stock", ["OP-restock", "OP-sell"], list(L0)) + "\n\n"
        text += code_lean.po3_statement("Stock") + " := " + code_lean.auto_po3_proof("ShopSys", "Stock", ["OP-restock", "OP-sell"], list(L0)) + "\n\n"

        text += """def Audit_impl_op_audit (i : L0_op_audit.Input) : L0_op_audit.Output :=
  { ok := decide (i.stock ≤ 100) }

theorem Audit_impl_op_audit_ok : ∀ i : L0_op_audit.Input, Audit_pre_op_audit i → Audit_post_op_audit i (Audit_impl_op_audit i) := by
  intro i hpre
  unfold Audit_post_op_audit Audit_impl_op_audit
  simp
"""
        text += code_lean.component_impl_def("ShopSys", "Audit", ["OP-audit"], list(L0)) + "\n\n"
        text += code_lean.po3_statement("Audit") + " := " + code_lean.auto_po3_proof("ShopSys", "Audit", ["OP-audit"], list(L0)) + "\n\n"

        text += code_lean.system_impl_def("ShopSys", ["Stock", "Audit"]) + "\n\n"
        text += code_lean.system_sound_instantiation("ShopSys", ["Stock", "Audit"]) + "\n"

        repo_root = HARNESS.parent
        with tempfile.NamedTemporaryFile("w", suffix=".lean", dir=str(repo_root), delete=False, encoding="utf-8") as f:
            f.write(text)
            temp_path = Path(f.name)

        try:
            res = subprocess.run(
                ["lake", "env", "lean", str(temp_path)],
                cwd=str(repo_root),
                capture_output=True,
                text=True,
                encoding="utf-8"
            )
            self.assertEqual(res.returncode, 0, f"Lean typecheck failed:\nSTDOUT:\n{res.stdout}\nSTDERR:\n{res.stderr}")
        finally:
            if temp_path.exists():
                temp_path.unlink()


if __name__ == "__main__":
    unittest.main()
