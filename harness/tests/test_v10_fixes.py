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


if __name__ == "__main__":
    unittest.main()
