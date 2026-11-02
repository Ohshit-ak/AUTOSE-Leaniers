"""Run from harness/:  python -m unittest discover -s tests

v10: repetitions and run comparison, always-derive fixup, truncation handling,
rule-built negative examples for data fields, specific vacuity feedback,
`has_precondition`, UI-only drops, string helpers, name lookup, undeclared fields."""
import importlib.util
import shutil
import sys
import unittest
from pathlib import Path

HARNESS = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(HARNESS))
HAS_LEAN = shutil.which("lake") is not None

_spec = importlib.util.spec_from_file_location("compare_runs", HARNESS.parent / "evaluation" / "compare_runs.py")
compare_runs = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(compare_runs)


class CompareRuns(unittest.TestCase):
    def test_verdict_uses_spread(self):
        v = compare_runs.verdict
        self.assertEqual(v("L0.5 pass", (50, 48, 52), (53, 52, 54), 3, 3), "within noise")
        self.assertEqual(v("L0.5 pass", (50, 49, 51), (55, 54, 56), 3, 3), "**better**")
        self.assertEqual(v("L0.5 fail", (5, 4, 6), (10, 9, 11), 3, 3), "**worse**")
        self.assertEqual(v("L0.5 pass", (50, 50, 50), (53, 53, 53), 1, 1), "single runs: no spread")

    def test_metrics(self):
        d = {"results": [{"id": "a", "compiles": True, "checked": True, "attempts": 1,
                          "rejects_bad_example": True, "l05": {"status": "pass"}},
                         {"id": "b", "compiles": False, "checked": False, "attempts": 3,
                          "rejects_bad_example": None, "l05": {"status": "fail"}}]}
        m = compare_runs.metrics(d)
        self.assertEqual((m["compiles"], m["L0.5 pass"], m["L0.5 fail"], m["mean attempts"]), (1, 1, 1, 2))


class RunFolders(unittest.TestCase):
    def test_repeat_folder_and_seed(self):
        import argparse
        import main
        a = argparse.Namespace(run_name=None, model="qwen", repeat=3, rep=2)
        self.assertEqual(main.run_dir("doc", a).parts[-2:], (f"qwen-{main.HARNESS_VERSION}", "rep2"))
        a = argparse.Namespace(run_name=None, model="qwen", repeat=None, rep=1)
        self.assertEqual(main.run_dir("doc", a).name, "qwen")
        import llm
        llm.set_seed(43)
        self.assertEqual(llm.current_seed("qwen"), 43)
        self.assertIsNone(llm.current_seed("gemma"))
        llm.set_seed(llm.SEED)


class AlwaysDerive(unittest.TestCase):
    def setUp(self):
        from agents.fixups import apply_fixups
        self.fix = lambda c: apply_fixups(c)[0]

    def test_adds_missing_deriving(self):
        out = self.fix("structure A where\n  x : Nat\n\ndef f := 1\n")
        self.assertIn("  x : Nat\n  deriving DecidableEq, Repr\n", out)

    def test_completes_existing_deriving(self):
        out = self.fix("structure B where\n  z : Bool\n  deriving Repr\n")
        self.assertIn("deriving Repr, DecidableEq", out)
        out = self.fix("structure C where\n  w : Nat\nderiving DecidableEq\n")
        self.assertIn("deriving DecidableEq, Repr", out)

    def test_leaves_complete_and_underivable_alone(self):
        ok = "structure D where\n  q : Nat\n  deriving DecidableEq, Repr\n"
        self.assertEqual(self.fix(ok), ok)
        fn = "structure E where\n  f : Nat → Bool\n"
        self.assertEqual(self.fix(fn), fn)
        rec = "structure T where\n  kids : List T\n"
        self.assertEqual(self.fix(rec), rec)

    @unittest.skipUnless(HAS_LEAN, "needs lake")
    def test_result_compiles(self):
        from lean_runner import check_lean
        code = self.fix("structure Item where\n  n : Nat\n\nstructure Input where\n  items : List Item\n"
                        "  deriving Repr\n\nexample : ({ items := [{ n := 1 }] } : Input) = { items := [{ n := 1 }] } "
                        ":= by decide\n")
        self.assertTrue(check_lean(code)["success"], code)


class Extraction(unittest.TestCase):
    def test_unclosed_fence_and_prose(self):
        from llm import extract_lean
        self.assertEqual(extract_lean("Here it is:\n```lean\nstructure A where\n  x : Nat\n"),
                         "structure A where\n  x : Nat")
        self.assertEqual(extract_lean("Some prose first.\n-- c\ndef Spec := 1\n```"), "-- c\ndef Spec := 1")

    def test_last_block_with_spec(self):
        from llm import extract_lean
        reply = "```lean\ndef a := 1\n```\n```lean\ndef Spec := 2\n```\n```lean\ndef b := 3\n```"
        self.assertEqual(extract_lean(reply), "def Spec := 2")

    def test_truncation_detection(self):
        from llm import is_truncated
        self.assertTrue(is_truncated("```lean\nx", "length"))
        self.assertFalse(is_truncated("```lean\nx", "stop"))
        self.assertTrue(is_truncated("```lean\nx", None))
        self.assertFalse(is_truncated("```lean\nx\n```", None))

    def test_truncated_reply_retried_then_reported(self):
        import llm
        calls = []

        def fake(prompt, system, model, history, temperature, max_tokens):
            calls.append(max_tokens)
            return "```lean\n.1.2.3", "length"
        orig = llm._call_llm_once
        llm._call_llm_once = fake
        try:
            with self.assertRaises(llm.Truncated):
                llm.call_llm("p", model="qwen")
        finally:
            llm._call_llm_once = orig
        self.assertEqual(calls, [llm.MAX_TOKENS, llm.MAX_TOKENS_RETRY])

    def test_loop_does_not_send_truncated_reply_to_lean(self):
        import agents.base as base
        replies = iter([base.TRUNCATED, "def Spec := 1\nexample : True := trivial"])
        checked = []
        orig_ask, orig_check = base._ask, base.check_lean
        base._ask = lambda *a, **k: next(replies)
        base.check_lean = lambda code: checked.append(code) or {"success": True}
        try:
            r = base.generate_verified("req", "sys", "qwen")
        finally:
            base._ask, base.check_lean = orig_ask, orig_check
        self.assertTrue(r["success"])
        self.assertEqual(len(checked), 1)
        self.assertEqual(r["log"][0]["stage"], "truncated")


DATA_SPEC = """structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔ (1 ≤ i.raw.length ∧ i.raw.length ≤ LIMIT ∧ i.raw.toList.all Char.isAlpha = true)

example : Spec.pre { raw := "ab" } ∧ Spec.post { raw := "ab" } { valid := true } := by
  unfold Spec; decide
"""
DATA_ENTRY = {"id": "DD-x", "kind": "data_constraint", "constraints": {"max_length": 5, "charset": "alphabetic"}}


class RuleNegatives(unittest.TestCase):
    def test_cases_from_rules(self):
        from agents.negative import rule_cases
        cases = rule_cases(DATA_SPEC.replace("LIMIT", "5"), DATA_ENTRY)
        self.assertEqual(len(cases), 2)  # too long, disallowed character (no min length)
        self.assertTrue(all(out == "{ valid := true }" for _, out, _ in cases))
        self.assertEqual(rule_cases(DATA_SPEC.replace("raw : String", "raw : String\n  n : Nat"), DATA_ENTRY), [])

    @unittest.skipUnless(HAS_LEAN, "needs lake")
    def test_verdicts_without_model(self):
        from agents.negative import NegativeCheck
        import agents.negative as neg
        orig = neg.call_llm
        neg.call_llm = lambda *a, **k: self.fail("data constraints must not call the model")
        try:
            good = DATA_SPEC.replace("LIMIT", "5")
            nc = NegativeCheck("", "qwen", entry=DATA_ENTRY)
            self.assertEqual(nc(good), [])
            self.assertEqual(nc.outcome(good)["negative_verdict"], "rejects")
            loose = DATA_SPEC.replace("LIMIT", "50")  # accepts 6 letters
            nc = NegativeCheck("", "qwen", entry=DATA_ENTRY)
            self.assertEqual(len(nc(loose)), 1)
            o = nc.outcome(loose)
            self.assertEqual((o["negative_verdict"], o["rejects_bad_example"]), ("accepts_forbidden", False))
            self.assertEqual(len(o["negative_examples"]), 2)
        finally:
            neg.call_llm = orig

    def test_unusable_model_example_is_unknown(self):
        from agents.negative import NegativeCheck
        import agents.negative as neg
        orig = neg.call_llm
        neg.call_llm = lambda *a, **k: "no records here"
        try:
            nc = NegativeCheck("req", "qwen", attempts=1)
            code = DATA_SPEC.replace("LIMIT", "5")
            self.assertEqual(nc(code), [])
            self.assertEqual(nc.outcome(code)["negative_verdict"], "unknown")
            self.assertIsNone(nc.outcome(code)["rejects_bad_example"])
        finally:
            neg.call_llm = orig


if __name__ == "__main__":
    unittest.main()
