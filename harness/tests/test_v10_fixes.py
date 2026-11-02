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


class VacuityFeedback(unittest.TestCase):
    CODE = """structure Input where
  q : Nat
  deriving DecidableEq, Repr

structure Output where
  results : List Nat
  shown   : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.shown = true ∨ o.shown = false

example : Spec.pre { q := 1 } ∧ Spec.post { q := 1 } { results := [1], shown := true } := by
  unfold Spec; decide
"""
    ENTRY = {"kind": "requirement", "text": "Results with 0 seeds will not be displayed. Each result is shown once."}

    def test_names_fields_and_quotes_requirement(self):
        import validate
        msg = validate.vacuity_feedback(self.CODE, ["results", "shown"],
                                        {"results": ("[1]", "[]"), "shown": ("true", "false")}, self.ENTRY)
        self.assertIn("`post` never mentions `o.results`", msg)
        self.assertIn('"Results with 0 seeds will not be displayed."', msg)
        self.assertIn("`o.shown` is `false` instead of `true`", msg)
        self.assertIn("Add a condition on `o.results`", msg)

    @unittest.skipUnless(HAS_LEAN, "needs lake")
    def test_hard_check_uses_detail(self):
        import validate
        problems = validate.hard_checks(self.ENTRY)(self.CODE)
        self.assertTrue(any("never mentions `o.results`" in p for p in problems), problems)


class Preconditions(unittest.TestCase):
    TRIVIAL = "def Spec : Contract Input Output where\n  pre  := fun _ => True\n  post := fun i o => o.x = i.x\n"

    def test_parser_cue(self):
        import req_parser
        doc = req_parser.parse_bytes(
            b"<srs><title><t>T</t></title><p id='3'><title>Functions</title><text_body>"
            b"The system shall encrypt all stored passwords. "
            b"If the cart is empty, the system shall block checkout.</text_body></p></srs>", "t.xml")
        flags = {r["text"][:10]: r["has_precondition"] for r in doc["requirements"]}
        self.assertEqual(flags, {"The system": False, "If the car": True})

    def test_flag_only_with_cue(self):
        import validate
        _, f = validate.check_parser_facts(self.TRIVIAL, {"kind": "requirement", "has_precondition": False})
        self.assertEqual(f, [])
        _, f = validate.check_parser_facts(self.TRIVIAL, {"kind": "requirement", "has_precondition": True})
        self.assertEqual(len(f), 1)


class UiDrops(unittest.TestCase):
    def parse(self, *sentences):
        import req_parser
        body = " ".join(sentences).encode()
        doc = req_parser.parse_bytes(b"<srs><title><t>T</t></title><p id='3'><title>Functions</title>"
                                     b"<text_body>" + body + b"</text_body></p></srs>", "t.xml")
        return doc

    def test_three_dropped(self):
        doc = self.parse("There will be a page button for the user to navigate the results.",
                         "Clicking the search button will open the results page.",
                         "The user can click on the Help link in the top menu.")
        self.assertEqual(doc["requirements"], [])
        self.assertEqual([d["reason"][:3] for d in doc["dropped"]], ["ui:"] * 3)

    def test_three_kept(self):
        doc = self.parse("Clicking the Add button will add the item to the cart.",
                         "Results will be sorted by date when the user clicks the column header.",
                         "The results page will display at most 100 results.")
        self.assertEqual(len(doc["requirements"]), 3, doc["dropped"])


class NameLookup(unittest.TestCase):
    CODE = ("structure Input where\n  query : String\n  deriving DecidableEq, Repr\n"
            "structure Output where\n  ok : Bool\n  deriving DecidableEq, Repr\n"
            "def Spec : Contract Input Output where\n  pre := fun i => i.bound > 0\n  post := fun i o => o.ok = true\n")

    def test_closest_by_edit_distance(self):
        from agents.repair import closest
        self.assertEqual(closest("isAlphabetic", ["isAlpha", "isDigit", "isUpper"])[0], "isAlpha")
        self.assertEqual(closest("zzzzzz", ["isAlpha"]), [])

    def test_no_hand_written_table(self):
        import agents.repair as repair
        self.assertFalse(hasattr(repair, "MISSING_API"))

    def test_unknown_identifier_suggests_helper(self):
        from agents.repair import hint_for
        self.assertIn("`allDigits`", hint_for("Unknown identifier `allDigit`", self.CODE))



if __name__ == "__main__":
    unittest.main()
