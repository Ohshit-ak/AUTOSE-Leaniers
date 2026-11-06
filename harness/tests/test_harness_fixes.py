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
import tempfile
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


class V7Fixes(unittest.TestCase):
    """Fixes for the issues found in runs/0000 - gamma j/qwen-v7."""

    def test_witness_is_one_line(self):
        from validate import example_witness
        code = ('def Spec := 1\n\nexample : Spec.pre { a := 1 } ∧\n'
                '  Spec.post { a := 1,\n               b := "x  y" }\n            { c := true } := by\n'
                '  unfold Spec; decide')
        inp, out = example_witness(code)
        self.assertEqual(inp, '{ a := 1, b := "x  y" }')  # spaces inside strings kept
        self.assertEqual(out, "{ c := true }")

    def test_negative_reply_forms(self):
        from agents.negative import _bad_values
        want = ("{ raw := \"ab\" }", "{ valid := true }")
        plain = '```lean\n-- why: too short\nIN  := { raw := "ab" }\nOUT := { valid := true }\n```'
        let = ('```lean\nexample : Spec.pre IN ∧ ¬ Spec.post IN OUT := by\n  unfold Spec\n'
               '  let IN := { raw := "ab" } -- too short\n  let OUT := { valid := true }\n  decide\n```')
        inline = ('```lean\nexample : Spec.pre { raw := "ab" } ∧ ¬ Spec.post { raw := "ab" } '
                  '{ valid := true } := by\n  unfold Spec; decide\n```')
        for reply in (plain, let, inline):
            self.assertEqual(_bad_values(reply), want, reply)

    def test_string_all_rewrite(self):
        from agents.fixups import apply_fixups
        code = ("structure Input where\n  raw : String\n  tags : List String\n"
                "def Spec := fun i => i.raw.all (·.isAlpha) ∧ i.tags.all (· ≠ \"\") ∧ i.raw.toList.any f")
        fixed, notes = apply_fixups(code)
        self.assertIn("i.raw.toList.all (·.isAlpha)", fixed)
        self.assertIn("i.tags.all", fixed)              # a list: unchanged
        self.assertIn("i.raw.toList.any f", fixed)      # already fine: unchanged
        self.assertTrue(notes)

    def test_slash_comment_rewrite_keeps_subtypes(self):
        from agents.fixups import apply_fixups
        fixed, _ = apply_fixups("  i.items) // Add product\ndef T := { x : Nat // x > 0 }")
        self.assertIn("i.items) -- Add product", fixed)
        self.assertIn("{ x : Nat // x > 0 }", fixed)

    def test_missing_collection_field_hint(self):
        from agents.repair import hint_for
        code = ("structure Input where\n  username : String\n  password : String\n"
                "  deriving DecidableEq, Repr\n\ndef Spec : Contract Input Output where\n"
                "  post := fun i o => o.signedIn = true ↔\n"
                "    ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password\n")
        hint = hint_for("error: Invalid field `accounts`: The environment does not contain "
                        "`Input.accounts`", code)
        self.assertIn("accounts : List Account", hint)
        self.assertIn("structure Account where\n  username : String\n  password : String", hint)

    def test_field_of_other_record_hint(self):
        from agents.repair import hint_for
        code = ("structure Input where\n  cart : List String\n  deriving DecidableEq, Repr\n\n"
                "structure Output where\n  done : Bool\n  deriving DecidableEq, Repr\n")
        hint = hint_for("error: `done` is not a field of structure `Input`", code)
        self.assertIn("write `o.done`", hint)

    def test_missing_api_entries(self):
        from agents.repair import hint_for
        for name in ("Function.sum", "String.substring", "List.nth"):
            owner, field = name.split(".")
            hint = hint_for(f"error: The environment does not contain `{owner}.{field}`", "")
            self.assertIn("does not exist", hint, name)


@unittest.skipUnless(shutil.which("lake"), "needs Lean (lake)")
class NumericDataTests(unittest.TestCase):
    QTY = ("structure Input where\n  value : Nat\n  stock : Nat\n  deriving DecidableEq, Repr\n\n"
           "structure Output where\n  valid : Bool\n  deriving DecidableEq, Repr\n\n"
           "def Spec : Contract Input Output where\n  pre  := fun _ => True\n"
           "  post := fun i o => o.valid = true ↔ 1 ≤ i.value ∧ i.value ≤ i.stock\n")
    ENTRY = {"kind": "data_constraint", "constraints": {"default": 1, "max_ref": "stock"}}

    def test_quantity_limit_passes(self):
        from validate import check_data_tests
        self.assertEqual(check_data_tests(self.QTY, self.ENTRY), [])

    def test_quantity_without_limit_is_flagged(self):
        from validate import check_data_tests
        loose = self.QTY.replace(" ∧ i.value ≤ i.stock", "")
        flags = check_data_tests(loose, self.ENTRY)
        self.assertEqual(len(flags), 1)
        self.assertIn("accepts an invalid value 6", flags[0])

    def test_money_without_bounds_is_not_flagged(self):
        from validate import check_data_tests
        money = self.QTY.replace("  stock : Nat\n", "").replace(" ∧ i.value ≤ i.stock", "")
        entry = {"kind": "data_constraint", "constraints": {"type": "money", "precision": "cents"}}
        self.assertEqual(check_data_tests(money, entry), [])


@unittest.skipUnless(shutil.which("lake"), "needs Lean (lake)")
class VacuityMultiLine(unittest.TestCase):
    def test_multiline_example_input_is_not_a_false_alarm(self):
        from validate import check_vacuity
        code = ("structure Input where\n  user : String\n  pw : String\n  deriving DecidableEq, Repr\n\n"
                "structure Output where\n  ok : Bool\n  deriving DecidableEq, Repr\n\n"
                "def Spec : Contract Input Output where\n  pre  := fun _ => True\n"
                "  post := fun i o => (o.ok = true ↔ i.pw = \"pw1\")\n\n"
                "example : Spec.pre { user := \"sam\", pw := \"pw1\" } ∧\n"
                "          Spec.post { user := \"sam\",\n                      pw := \"pw1\" }\n"
                "                    { ok := true } := by\n  unfold Spec; decide\n")
        self.assertEqual(check_vacuity(code)[0], [])


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


@unittest.skipUnless(shutil.which("lake"), "needs Lean (lake)")
class TestHarnessFixes(unittest.TestCase):
    def test_utf8_lean_check(self):
        import lean_runner

        # Lean code containing Unicode characters like ← and →
        code = "-- arrows: a → b ∧ c ← d\nexample : 1 = 1 := rfl"
        res = lean_runner.check_lean(code)
        self.assertTrue(res.get("success"), res.get("error"))

        # core_names writes _NAMES_SCRIPT containing ←
        mock_output = mock.Mock(returncode=0, stdout="Nat.add\nString.length\n", stderr="")
        with tempfile.TemporaryDirectory() as tmpdir:
            temp_cache = Path(tmpdir) / "cf_core_names.json"
            with mock.patch.object(lean_runner, "_NAMES_CACHE", temp_cache), \
                 mock.patch("subprocess.run", return_value=mock_output):
                names = lean_runner.core_names()
                self.assertIn("Nat", names)
                self.assertIn("add", names["Nat"])
                # Verify reading cached JSON works
                cached = lean_runner.core_names()
                self.assertEqual(names, cached)


if __name__ == "__main__":
    unittest.main()
