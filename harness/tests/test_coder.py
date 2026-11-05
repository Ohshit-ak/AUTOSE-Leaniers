"""Unit tests for L2 coding agent (harness/agents/coding_agent.py)."""
import shutil
import sys
import unittest
from pathlib import Path

HARNESS = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(HARNESS))

import code_lean
import arch_lean
from agents import coding_agent

HAS_LEAN = shutil.which("lake") is not None


class TestOpCoderValidation(unittest.TestCase):
    def test_validator_rejects_sorry_and_admit(self):
        v = coding_agent.validate_op_code("Stock", "OP-restock")
        bad_code_sorry = """
def Stock_impl_op_restock (i : L0_op_restock.Input) : L0_op_restock.Output :=
  { stock := i.stock + i.amount }

theorem Stock_impl_op_restock_ok : ∀ i : L0_op_restock.Input, Stock_pre_op_restock i → Stock_post_op_restock i (Stock_impl_op_restock i) := by
  sorry
"""
        problems = v(bad_code_sorry)
        self.assertTrue(any("sorry" in p.lower() for p in problems))

        bad_code_admit = bad_code_sorry.replace("sorry", "admit")
        problems = v(bad_code_admit)
        self.assertTrue(any("admit" in p.lower() for p in problems))

        bad_code_native = bad_code_sorry.replace("sorry", "native_decide")
        problems = v(bad_code_native)
        self.assertTrue(any("native_decide" in p.lower() for p in problems))

        bad_code_axiom = bad_code_sorry.replace("sorry", "axiom")
        problems = v(bad_code_axiom)
        self.assertTrue(any("axiom" in p.lower() for p in problems))

    def test_validator_rejects_missing_names(self):
        v = coding_agent.validate_op_code("Stock", "OP-restock")
        missing_impl = """
def WrongName (i : L0_op_restock.Input) : L0_op_restock.Output :=
  { stock := i.stock + i.amount }

theorem Stock_impl_op_restock_ok : ∀ i : L0_op_restock.Input, Stock_pre_op_restock i → Stock_post_op_restock i (WrongName i) := by
  rfl
"""
        problems = v(missing_impl)
        self.assertTrue(any("Stock_impl_op_restock" in p for p in problems))

        missing_ok = """
def Stock_impl_op_restock (i : L0_op_restock.Input) : L0_op_restock.Output :=
  { stock := i.stock + i.amount }
"""
        problems = v(missing_ok)
        self.assertTrue(any("Stock_impl_op_restock_ok" in p for p in problems))

    def test_validator_accepts_valid(self):
        v = coding_agent.validate_op_code("Stock", "OP-restock")
        valid_code = """
def Stock_impl_op_restock (i : L0_op_restock.Input) : L0_op_restock.Output :=
  { stock := i.stock + i.amount }

theorem Stock_impl_op_restock_ok : ∀ i : L0_op_restock.Input, Stock_pre_op_restock i → Stock_post_op_restock i (Stock_impl_op_restock i) := by
  intro i hpre
  unfold Stock_post_op_restock Stock_impl_op_restock
  rfl
"""
        self.assertEqual(v(valid_code), [])

        # Accepts 'lemma' as well
        valid_lemma = valid_code.replace("theorem Stock_impl_op_restock_ok", "lemma Stock_impl_op_restock_ok")
        self.assertEqual(v(valid_lemma), [])


class TestComponentCoder(unittest.TestCase):
    def test_component_coder_mock_success(self):
        mock_ops = {
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

        def mock_op_coder(comp, op, locked_context, model):
            return {"op": op, "comp": comp, **mock_ops[op]}

        res = coding_agent.run_component_coder(
            group="ShopSys",
            comp="Stock",
            owned=["OP-restock", "OP-sell"],
            all_ops=["OP-restock", "OP-sell", "OP-audit"],
            locked_context="",
            model="mock",
            op_coder_fn=mock_op_coder,
            skip_lean=True,
        )

        self.assertTrue(res["success"])
        self.assertTrue(res["proved"])
        self.assertIn("Stock_impl_op_restock", res["code"])
        self.assertIn("Stock_impl_op_sell", res["code"])
        self.assertIn("def StockImpl (m : ShopSysMsg)", res["code"])
        self.assertIn("theorem StockImpl_ok : StockContract.Satisfies StockImpl", res["code"])

    def test_component_coder_op_failure(self):
        def mock_failing_op_coder(comp, op, locked_context, model):
            return {"op": op, "comp": comp, "success": False, "error": "timeout"}

        res = coding_agent.run_component_coder(
            group="ShopSys",
            comp="Stock",
            owned=["OP-restock"],
            all_ops=["OP-restock", "OP-sell"],
            locked_context="",
            model="mock",
            op_coder_fn=mock_failing_op_coder,
            skip_lean=True,
        )

        self.assertFalse(res["success"])
        self.assertFalse(res["proved"])
        self.assertIn("OP-restock", res["error"])
        self.assertIn("timeout", res["error"])

    def test_component_coder_empty_owned(self):
        res = coding_agent.run_component_coder(
            group="ShopSys",
            comp="EmptyComp",
            owned=[],
            all_ops=["OP-restock"],
            locked_context="",
            model="mock",
            skip_lean=True,
        )

        self.assertTrue(res["success"])
        self.assertTrue(res["proved"])
        self.assertIn("def EmptyCompImpl (m : ShopSysMsg)", res["code"])
        self.assertIn("theorem EmptyCompImpl_ok : EmptyCompContract.Satisfies EmptyCompImpl", res["code"])


@unittest.skipUnless(HAS_LEAN, "lake not installed")
class TestLeanComponentIntegration(unittest.TestCase):
    def test_component_coder_lean_typecheck(self):
        from tests.test_arch import L0, DOMAIN, STOCK, AUDIT

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
        self.assertTrue(res_stock["success"])
        self.assertTrue(res_stock["proved"])


class TestMainStageCode(unittest.TestCase):
    def test_main_stages_definition(self):
        import main
        self.assertIn("code", main.STAGES)
        self.assertIn("code", main.L2_STAGES)
        self.assertEqual(main.L2_VERSION, "L2-v1")
        self.assertTrue(callable(getattr(main, "stage_code", None)))

    def test_main_stage_code_execution(self):
        import argparse
        import json
        import tempfile
        from unittest.mock import patch
        import main

        with tempfile.TemporaryDirectory() as tmpdir:
            tmppath = Path(tmpdir)
            stem = "test_stem"
            arch_dir = tmppath / stem / "mock-L1-v1" / "arch"
            group_dir = arch_dir / "ShopSys"
            group_dir.mkdir(parents=True)

            (group_dir / "Arch.lean").write_text("-- mock Arch.lean\n", encoding="utf-8")
            arch_json = {
                "group": "ShopSys",
                "verdict": "accepted",
                "order": ["Stock"],
                "contracts": {
                    "Stock": {"ops": {"OP-restock": {}}}
                },
                "operations": {"OP-restock": {}}
            }
            (group_dir / "arch.json").write_text(json.dumps(arch_json), encoding="utf-8")

            args = argparse.Namespace(
                model="mock",
                run_name=None,
                repeat=None,
                rep=1,
                skip_lean=True,
                component=None,
                arch_run=str(arch_dir),
                until="code",
            )

            mock_op_res = {
                "component": "Stock",
                "code": "def Stock_impl_op_restock : Nat := 0\n\ntheorem Stock_impl_op_restock_ok : True := trivial\n",
                "success": True,
                "proved": True,
                "ops": {"OP-restock": {"success": True}}
            }

            with patch("main.RUNS_DIR", tmppath), \
                 patch("agents.coding_agent.run_component_coder", return_value=mock_op_res):
                summary = main.stage_code(stem, args)

            self.assertIn("ShopSys", summary["groups"])
            self.assertEqual(summary["groups"]["ShopSys"]["verdict"], "accepted")

            code_out = tmppath / stem / "mock-L2-v1" / "code"
            self.assertTrue((code_out / "ShopSys" / "Impl.lean").exists())
            self.assertTrue((code_out / "ShopSys" / "code.json").exists())
            self.assertTrue((code_out / "summary.json").exists())

    def test_main_cli_args_parsing(self):
        import argparse
        import main

        # Create parser identical to main
        ap = argparse.ArgumentParser()
        ap.add_argument("--until", choices=main.STAGES)
        ap.add_argument("--arch-run")

        args = ap.parse_args(["--until", "code", "--arch-run", "some/path/arch"])
        self.assertEqual(args.until, "code")
        self.assertEqual(args.arch_run, "some/path/arch")

    def test_stage_code_nonexistent_arch_run_fails(self):
        import argparse
        import main

        args = argparse.Namespace(
            model="mock",
            arch_run="nonexistent/directory/path/that/does/not/exist",
            component=None,
        )
        with self.assertRaises(SystemExit) as ctx:
            main.stage_code("some_stem", args)
        self.assertIn("arch run directory not found", str(ctx.exception))


if __name__ == "__main__":
    unittest.main()
