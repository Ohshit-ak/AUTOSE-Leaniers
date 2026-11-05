"""Standalone End-to-End L2 Verification for ShopSys."""
import subprocess
import sys
import tempfile
from pathlib import Path

HARNESS = Path(__file__).resolve().parent
ROOT = HARNESS.parent
sys.path.insert(0, str(HARNESS))

import arch_lean
import code_lean
from agents import coding_agent
from tests.test_arch import AUDIT, DOMAIN, L0, STOCK


def main():
    print("=== Step 1: Building locked L0/L1 architecture context ===")
    context = """import ContractForge.Contract
import ContractForge.Chain
import ContractForge.Soundness
open ContractForge

"""
    context += DOMAIN + "\n"
    context += arch_lean.locked_context("ShopSys", L0) + "\n\n"
    context += STOCK + "\n\n"
    context += AUDIT + "\n\n"
    context += arch_lean.contract_def("ShopSys", "Stock", ["OP-restock", "OP-sell"], list(L0)) + "\n\n"
    context += arch_lean.contract_def("ShopSys", "Audit", ["OP-audit"], list(L0)) + "\n\n"

    for comp, op in [("Stock", "OP-restock"), ("Stock", "OP-sell"), ("Audit", "OP-audit")]:
        stmt = arch_lean.trace_statements(comp, op)
        s = arch_lean.slug(op)
        context += f"{stmt['pre']} := by unfold {arch_lean.pre_name(comp, op)} L0_{s}.Spec; intro i h; exact h\n\n"
        context += f"{stmt['post']} := by unfold {arch_lean.post_name(comp, op)} L0_{s}.Spec; intro i o h1 h2; exact h2\n\n"

    owner = {"OP-restock": "Stock", "OP-sell": "Stock", "OP-audit": "Audit"}
    context += arch_lean.po1_statement("Stock", "Audit") + " := " + arch_lean.auto_po1_proof("ShopSys", "Stock", "Audit", owner, list(L0)) + "\n\n"
    context += arch_lean.po2_statement("ShopSys", ["Stock", "Audit"]) + " := " + arch_lean.auto_po2_proof("ShopSys", ["Stock", "Audit"], owner, list(L0)) + "\n\n"
    context += arch_lean.system_sound_theorem("ShopSys", ["Stock", "Audit"]) + "\n\n"

    print("=== Step 2: Running L2 Coding Agent for Stock ===")
    mock_stock_ops = {
        "OP-restock": {
            "success": True,
            "code": """def Stock_impl_op_restock (i : L0_op_restock.Input) : L0_op_restock.Output :=
  { stock := i.stock + i.amount }

theorem Stock_impl_op_restock_ok : ∀ i : L0_op_restock.Input, Stock_pre_op_restock i → Stock_post_op_restock i (Stock_impl_op_restock i) := by
  intro i hpre
  unfold Stock_post_op_restock Stock_impl_op_restock
  rfl"""
        },
        "OP-sell": {
            "success": True,
            "code": """def Stock_impl_op_sell (i : L0_op_sell.Input) : L0_op_sell.Output :=
  { stock := i.stock - 1, sold := true }

theorem Stock_impl_op_sell_ok : ∀ i : L0_op_sell.Input, Stock_pre_op_sell i → Stock_post_op_sell i (Stock_impl_op_sell i) := by
  intro i hpre
  dsimp [Stock_post_op_sell, Stock_impl_op_sell, Stock_pre_op_sell] at *
  refine ⟨by omega, rfl⟩"""
        }
    }

    res_stock = coding_agent.run_component_coder(
        group="ShopSys",
        comp="Stock",
        owned=["OP-restock", "OP-sell"],
        all_ops=["OP-restock", "OP-sell", "OP-audit"],
        locked_context=context,
        model="mock",
        op_coder_fn=lambda c, o, ctx, m: {"op": o, "comp": c, **mock_stock_ops[o]},
        skip_lean=False,
    )
    assert res_stock["success"], f"Stock failed: {res_stock.get('error')}"
    print("Stock component verified (PO3 satisfied)!")

    print("=== Step 3: Running L2 Coding Agent for Audit ===")
    mock_audit_ops = {
        "OP-audit": {
            "success": True,
            "code": """def Audit_impl_op_audit (i : L0_op_audit.Input) : L0_op_audit.Output :=
  { ok := decide (i.stock ≤ 100) }

theorem Audit_impl_op_audit_ok : ∀ i : L0_op_audit.Input, Audit_pre_op_audit i → Audit_post_op_audit i (Audit_impl_op_audit i) := by
  intro i hpre
  unfold Audit_post_op_audit Audit_impl_op_audit
  simp"""
        }
    }

    res_audit = coding_agent.run_component_coder(
        group="ShopSys",
        comp="Audit",
        owned=["OP-audit"],
        all_ops=["OP-restock", "OP-sell", "OP-audit"],
        locked_context=context,
        model="mock",
        op_coder_fn=lambda c, o, ctx, m: {"op": o, "comp": c, **mock_audit_ops[o]},
        skip_lean=False,
    )
    assert res_audit["success"], f"Audit failed: {res_audit.get('error')}"
    print("Audit component verified (PO3 satisfied)!")

    print("=== Step 4: Assembling composite Impl.lean ===")
    system_impl = code_lean.system_impl_def("ShopSys", ["Stock", "Audit"])
    sound_inst = code_lean.system_sound_instantiation("ShopSys", ["Stock", "Audit"])
    full_lean = f"{context}\n\n{res_stock['code']}\n\n{res_audit['code']}\n\n{system_impl}\n\n{sound_inst}\n"

    assert "sorry" not in full_lean, "Found sorry in generated Lean code!"
    assert "admit" not in full_lean, "Found admit in generated Lean code!"

    print("=== Step 5: Type-checking Impl.lean with Lean 4 Kernel ===")
    with tempfile.NamedTemporaryFile("w", suffix=".lean", dir=str(ROOT), delete=False, encoding="utf-8") as f:
        f.write(full_lean)
        temp_path = Path(f.name)

    try:
        proc = subprocess.run(
            ["lake", "env", "lean", str(temp_path)],
            cwd=str(ROOT),
            capture_output=True,
            text=True,
            encoding="utf-8"
        )
        if proc.returncode != 0:
            print("Lean compilation error:")
            print(proc.stderr or proc.stdout)
            sys.exit(1)
        print("Lean typecheck: SUCCESS (return code 0)")
        print("Verified theorems in kernel:")
        print("  - StockImpl_ok: StockContract.Satisfies StockImpl")
        print("  - AuditImpl_ok: AuditContract.Satisfies AuditImpl")
        print("  - system_sound_ShopSys_inst: ShopSysSystemSpec.Satisfies ShopSysSystemImpl")
    finally:
        if temp_path.exists():
            temp_path.unlink()

    print("\nALL VERIFICATIONS PASSED SUCCESSFULLY!")


if __name__ == "__main__":
    main()
