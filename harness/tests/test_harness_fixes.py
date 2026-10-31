"""Run from harness/:  python -m unittest discover -s tests

Regression tests for harness bugs seen in runs/0000 - gamma j/qwen-v6:
  - a reply with two ```lean blocks was saved with Input/Output/Spec declared twice;
  - an example-only repair with no `example` appended the whole reply to the locked defs;
  - Lean 4's "declaration uses `sorry`" (backticks) was not caught;
  - a failed entry kept its last attempt even when an earlier one compiled.
The `sorry` test needs Lean (`lake`) and a built framework; the rest need neither.
"""
import shutil
import sys
import unittest
from pathlib import Path
from unittest import mock

HARNESS = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(HARNESS))

from agents import base  # noqa: E402
from llm import extract_lean  # noqa: E402

DRAFT = """\
structure Input where
  raw : String

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔ i.raw.toList.Sublist 0 2

example : True := trivial"""

CORRECTED = DRAFT.replace("i.raw.toList.Sublist 0 2", "i.raw.length = 5")


class ExtractLean(unittest.TestCase):
    def test_two_blocks_keeps_only_the_last_spec(self):
        reply = f"First try:\n```lean\n{DRAFT}\n```\nFixed:\n```lean\n{CORRECTED}\n```"
        code = extract_lean(reply)
        self.assertEqual(code, CORRECTED)
        self.assertEqual(code.count("def Spec"), 1)

    def test_prefers_block_with_spec_over_a_trailing_snippet(self):
        reply = f"```lean\n{CORRECTED}\n```\nYou can check it with:\n```lean\n#eval 1\n```"
        self.assertEqual(extract_lean(reply), CORRECTED)

    def test_example_only_reply_is_kept(self):
        reply = "```lean\nexample : Spec.pre {} := by\n  unfold Spec; decide\n```"
        self.assertTrue(extract_lean(reply).startswith("example"))

    def test_no_fence_returns_text(self):
        self.assertEqual(extract_lean("<think>hm</think>\n  def x := 1  "), "def x := 1")


class LockedDefs(unittest.TestCase):
    DEFS = "structure Input where\n  raw : String\n\ndef Spec : Contract Input Output where"
    OLD_EXAMPLE = "example : old := by decide"

    def test_uses_example_from_reply(self):
        code = base.with_locked_defs(self.DEFS, "example : new := by decide", self.OLD_EXAMPLE)
        self.assertEqual(code, f"{self.DEFS}\n\nexample : new := by decide")

    def test_reply_without_example_does_not_duplicate_defs(self):
        reply = "structure Input where\n  raw : String\n\ndef Spec : Contract Input Output where"
        code = base.with_locked_defs(self.DEFS, reply, self.OLD_EXAMPLE)
        self.assertEqual(code.count("structure Input"), 1)
        self.assertTrue(code.endswith(self.OLD_EXAMPLE))

    def test_reply_with_full_code_keeps_locked_defs(self):
        reply = "structure Input where\n  changed : Nat\n\nexample : new := by decide"
        code = base.with_locked_defs(self.DEFS, reply, self.OLD_EXAMPLE)
        self.assertNotIn("changed", code)
        self.assertEqual(code.count("structure Input"), 1)


class BestAttempt(unittest.TestCase):
    """Attempt 1 compiles but fails L0.5; later repairs break compilation."""

    def test_returns_furthest_attempt_not_last(self):
        replies = iter(["```lean\ndef Spec := GOOD o.x\n```"]
                       + [f"```lean\ndef Spec := BAD{n} o.x\n```" for n in range(10)])
        fake_llm = lambda *a, **k: next(replies)  # noqa: E731

        def fake_lean(code):
            if "GOOD" in code:
                return {"success": True, "output": ""}
            return {"success": False, "error": f"x.lean:1:0: error: unknown thing {code[-6:]}"}

        with mock.patch.object(base, "call_llm", fake_llm), \
                mock.patch.object(base, "_ask", fake_llm), \
                mock.patch.object(base, "check_lean", fake_lean), \
                mock.patch.object(base, "MAX_RETRIES", 4):
            r = base.generate_verified("req", "sys", "m", validate=lambda c: ["trivial post"])

        self.assertFalse(r["success"])
        self.assertIn("GOOD", r["code"])
        self.assertTrue(r["error"].startswith("L0.5"))
        self.assertEqual(r["log"][-1], {"attempt": 1, "stage": "returned"})


class SpecChecks(unittest.TestCase):
    """Static checks and hints for qwen-v6 3.1.3/S3, 3.2.3/S1 and 5.3/R5."""

    def test_self_equation_is_flagged(self):
        from validate import check_contradictions
        code = "def Spec : Contract Input Output where\n  post := fun i o => (a.failedAttempts + 1) = a.failedAttempts"
        self.assertEqual(len(check_contradictions(code)), 1)
        self.assertEqual(len(check_contradictions("  post := fun i o => o.n = o.n + 2")), 1)

    def test_real_updates_are_not_flagged(self):
        from validate import check_contradictions
        for ok in ["o.n = i.n + 1", "i.n + 1 = o.n", "o.pending = i.pending - 1",
                   "a.n + 1 = a.n + 1", "x + 1 = xs.length", "o.n = i.n + 0"]:
            self.assertEqual(check_contradictions(f"  post := fun i o => {ok}"), [], ok)

    def test_example_only_is_not_checked_for_contradictions(self):
        from validate import check_contradictions
        self.assertEqual(check_contradictions("def Spec := 1\n\nexample : x + 1 = x := sorry"), [])

    def test_different_example_inputs_are_flagged(self):
        from validate import check_example_inputs
        same = ("def Spec := 1\n\nexample : Spec.pre { n := 1 } ∧\n"
                "  Spec.post { n := 1 } { m := 2 } := by\n  unfold Spec; decide")
        self.assertEqual(check_example_inputs(same), [])
        self.assertEqual(len(check_example_inputs(same.replace("post { n := 1 }", "post { n := 3 }"))), 1)

    def test_self_containing_structure_hint(self):
        from agents.repair import contains_itself, hint_for
        code = ("structure Category where\n  name : String\n  categories : List Category\n"
                "  deriving DecidableEq, Repr\n")
        self.assertTrue(contains_itself(code, "Category"))
        self.assertFalse(contains_itself(code.replace("List Category", "List Nat"), "Category"))
        hint = hint_for("error: None of the deriving handlers for class `DecidableEq` applied to "
                        "`Category`", code)
        self.assertIn("parent : Option Nat", hint)

    def test_duplicate_field_hint(self):
        from agents.repair import hint_for
        code = "structure Output where\n  profile_updated : Bool\n  deriving DecidableEq, Repr\n"
        hint = hint_for("error: field `profile_updated` has already been specified", code)
        self.assertIn("exactly the record given to `Spec.pre`", hint)


@unittest.skipUnless(shutil.which("lake"), "needs Lean (lake)")
class SorryDetection(unittest.TestCase):
    def test_sorry_is_a_failure(self):
        from lean_runner import check_lean
        r = check_lean("example : 1 = 1 := by sorry")
        self.assertFalse(r["success"])
        self.assertIn("sorry", r["error"])

    def test_real_proof_passes(self):
        from lean_runner import check_lean
        self.assertTrue(check_lean("example : 1 = 1 := rfl")["success"])


if __name__ == "__main__":
    unittest.main()
