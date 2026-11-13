"""Run from harness/:  python -m unittest tests.test_v11_fixes

v11 fixes for the failure patterns (docs/failure_patterns.pdf). Every fixture here is a toy
spec; nothing names a field or requirement of a real SRS."""
import shutil
import sys
import unittest
from pathlib import Path
from unittest import mock

HARNESS = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(HARNESS))

import chain_checks as C  # noqa: E402
import skeleton as S  # noqa: E402
import spec_checks as SC  # noqa: E402
from agents import repair  # noqa: E402
from validate import field_types  # noqa: E402

from tests.test_chain import GOOD, HIDDEN_FIELD, IDENTITY, SPEC, USES_INPUT_VAR, Scripted, fenced  # noqa: E402

HAS_LEAN = shutil.which("lake") is not None

ITEMS = """structure Item where
  id : Nat
  deriving DecidableEq, Repr

structure Input where
  items : List Item
  limit : Nat
  deriving DecidableEq, Repr

structure Output where
  items : List Item
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.limit > 0
  post := fun i o => {post}

example : Spec.pre {{ items := [{{ id := 1 }}], limit := 1 }} ∧ Spec.post {{ items := [{{ id := 1 }}], limit := 1 }} {{ items := [{{ id := 1 }}] }} := by
  unfold Spec; decide
"""

MODES = """structure Input where
  mode : String
  qty : Nat
  name : String
  deriving DecidableEq, Repr

structure Output where
  ok : Bool
  msg : String
  level : Nat
  name : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.qty > 0
  post := fun i o => (o.ok = true ↔ i.qty ≤ 10) ∧ o.msg = "done" ∧
                     (i.mode = "fast" → o.level = 2) ∧ (¬ i.mode = "fast" → o.level = 1)
"""


class CopyOk(unittest.TestCase):
    def test_echo_requirement_is_copy_ok(self):
        self.assertTrue(SC.copy_ok({"kind": "requirement", "text": "The system shall display the user's name."}))

    def test_decision_or_condition_is_not_copy_ok(self):
        for text in ("The system shall validate and display the order.",
                     "The system shall display the order only if it is paid.",
                     "The system shall store at most 10 items.",
                     "The system shall receive messages."):          # boilerplate verb: not an echo
            self.assertFalse(SC.copy_ok({"kind": "requirement", "text": text}), text)

    def test_data_constraint_never_copy_ok(self):
        self.assertFalse(SC.copy_ok({"kind": "data_constraint", "text": "display name"}))


class OutputMention(unittest.TestCase):
    def test_input_only_conjunct_textual(self):
        code = ITEMS.format(post="o.items = i.items ∧ i.limit ≤ 3")
        found = SC.unrealizable_conjuncts(code, lean=False)
        self.assertEqual([c for c, _, used in found], ["i.limit ≤ 3"])

    def test_input_only_after_substituting_a_copy(self):
        code = ITEMS.format(post="o.items = i.items ∧ ∀ t ∈ o.items, t.id ≠ 0")
        found = SC.unrealizable_conjuncts(code, lean=False)
        self.assertEqual(len(found), 1)
        self.assertIn("i.items", found[0][1])
        self.assertEqual(found[0][2], ["items"])

    def test_iff_is_not_a_fixed_output(self):
        code = ITEMS.format(post="(∀ t ∈ o.items, t.id ≠ 0) ∧ (o.items = [] ↔ i.items = [])")
        self.assertEqual(SC.unrealizable_conjuncts(code, lean=False), [])

    def test_filter_spec_is_fine(self):
        code = ITEMS.format(post="(∀ t ∈ o.items, t ∈ i.items ∧ t.id ≠ 0)")
        self.assertEqual(SC.unrealizable_conjuncts(code, lean=False), [])

    @unittest.skipUnless(HAS_LEAN, "needs lake")
    def test_implied_by_pre_is_not_reported(self):
        code = ITEMS.format(post="o.items = i.items ∧ i.limit ≥ 1")
        self.assertEqual(SC.unrealizable_conjuncts(code), [])
        code = ITEMS.format(post="o.items = i.items ∧ i.limit ≤ 3")
        self.assertEqual(len(SC.output_mention_problems(code)), 1)
        self.assertIn("move it to `pre`", SC.output_mention_problems(code)[0])

    @unittest.skipUnless(HAS_LEAN, "needs lake")
    def test_loop_checks_report_weak_once(self):
        code = ITEMS.format(post="∀ t ∈ o.items, t ∈ i.items")        # a copy satisfies it
        check = SC.loop_checks({"kind": "requirement", "text": "The system shall remove items."})
        first = check(code)
        self.assertEqual(len(first), 1)
        self.assertIn("too weak", first[0])
        self.assertEqual(check(code), [])                               # accepted the second time
        echo = SC.loop_checks({"kind": "requirement", "text": "The system shall display the items."})
        self.assertEqual(echo(code), [])                                # copy-ok: never reported

    @unittest.skipUnless(HAS_LEAN, "needs lake")
    def test_strength_record(self):
        code = ITEMS.format(post="∀ t ∈ o.items, t ∈ i.items")
        st = SC.spec_strength(code, {"kind": "requirement", "text": "The system shall remove items."})
        self.assertEqual(st["class"], "weak")
        self.assertTrue(st["trivial"])


class Skeleton(unittest.TestCase):
    def setUp(self):
        self.c = C.spec_contract(MODES)
        self.fields = field_types(MODES)

    def test_derives_fields_from_post(self):
        sk = S.build(self.c, self.fields, "SpecImpl")
        self.assertEqual(sk.values["ok"], "decide (x.qty ≤ 10)")
        self.assertEqual(sk.values["msg"], '"done"')
        self.assertEqual(sk.values["level"], 'if x.mode = "fast" then 2 else 1')
        self.assertEqual(sk.values["name"], "x.name")                 # unconstrained: same-named input
        self.assertTrue(sk.complete)

    def test_one_sided_branch_leaves_a_hole(self):
        c = C.Contract("Spec", "Input", "Output", "i", "True", "i", "o", '(i.mode = "fast" → o.level = 2)')
        sk = S.build(c, self.fields, "SpecImpl")
        self.assertIn(S.FILL, sk.values["level"])
        self.assertFalse(sk.complete)
        self.assertIn("FILL", S.prompt_text(sk))

    def test_filter_and_take(self):
        code = ITEMS.format(post="(∀ t ∈ o.items, t.id ≠ 0) ∧ o.items.length ≤ i.limit")
        sk = S.build(C.spec_contract(code), field_types(code), "SpecImpl")
        self.assertEqual(sk.values["items"], "(x.items.filter (fun t => decide (t.id ≠ 0))).take i.limit"
                         .replace("take i.limit", "take x.limit"))
        self.assertEqual(sk.hints, [])

    def test_action_names_the_branch(self):
        a = S.action_for('i.mode = "fast" → o.level = 2', self.c, self.fields)
        self.assertIn('add a branch on `x.mode = "fast"`', a)

    def test_provenance(self):
        sk = S.build(self.c, self.fields, "SpecImpl")
        code = S.render(sk).replace('"done"', '"other"')
        p = S.provenance(code, sk)
        self.assertIn("ok", p["harness"])
        self.assertEqual(p["model"], ["msg"])

    @unittest.skipUnless(HAS_LEAN, "needs lake")
    def test_complete_skeleton_proves_without_the_model(self):
        import agents.base as base
        from agents.chain_coder import run_coder
        with mock.patch.object(base, "call_llm", lambda *a, **k: self.fail("no model call expected")):
            r = run_coder("Spec", MODES, "fake")
        self.assertTrue(r["success"], r.get("error"))
        self.assertTrue(r["harness_only"])
        self.assertEqual(r["attempts"], 0)
        self.assertIn("level", r["fields"]["harness"])


class CarryFields(unittest.TestCase):
    def test_hidden_field_is_carried(self):
        out, added = C.carry_input_fields(HIDDEN_FIELD, SPEC)
        self.assertEqual(added, ["stock"])
        self.assertIn("stock : Nat", out)
        self.assertNotIn("has no field", " ".join(C.static_check(out, SPEC)["problems"]))
        self.assertEqual(C.spec_contract(SPEC), C.spec_contract(SPEC + "\n" + out))   # Spec untouched

    def test_foreign_variable_rewritten(self):
        out, added = C.carry_input_fields(USES_INPUT_VAR, SPEC)
        self.assertIn("stock", added)
        self.assertNotIn("is not one of its variables", " ".join(C.static_check(out, SPEC)["problems"]))

    def test_nothing_to_do(self):
        self.assertEqual(C.carry_input_fields(GOOD, SPEC), (GOOD, []))


@unittest.skipUnless(HAS_LEAN, "needs lake")
class LeanDocs(unittest.TestCase):
    def test_invented_name_gets_real_entries(self):
        import lean_docs
        refs = lean_docs.lookup("Invalid field `last`: The environment does not contain `List.last`")
        self.assertTrue(refs[0].startswith("- `List.getLast? : List α → Option α`"))
        self.assertLessEqual(len(refs), lean_docs.MAX_ENTRIES)

    def test_missing_instance_gets_functions(self):
        import lean_docs
        refs = lean_docs.lookup("failed to synthesize instance of type class\n  SDiff (List String)")
        self.assertTrue(any("List.removeAll" in r for r in refs))

    def test_feedback_quotes_entries(self):
        out = "<generated>:4:10: error: Unknown constant `List.nth`"
        text = repair.format_feedback("a\nb\nc\nd\ne", out)
        self.assertIn("Real Lean definitions", text)


class Ladder(unittest.TestCase):
    """base.generate_verified: same check again → fresh prompt, then the hint, then stop."""

    def run_loop(self, replies, error, **kw):
        import agents.base as base
        model = Scripted(replies)
        with mock.patch.object(base, "call_llm", model), mock.patch.object(base, "MAX_RETRIES", 6), \
                mock.patch.object(base, "check_lean", lambda code: {"success": False, "error": error}):
            r = base.generate_verified("P", "S", "fake", **kw)
        return r, model

    def test_strategy_order_and_stop(self):
        err = "<generated>:5:1: error: unknown identifier `foo`"
        r, model = self.run_loop([f"def a{k} := 1" for k in range(6)], err,
                                 strategy_hint=lambda code, e: "HINT")
        strategies = [x.get("strategy") for x in r["log"] if "strategy" in x]
        self.assertEqual(strategies, ["fresh", "fresh+hint"])
        self.assertIn("HINT", model.prompts[3])
        self.assertTrue(r["stopped"])
        self.assertLess(r["attempts"], 6)

    def test_identical_failures_stop_early(self):
        err = "<generated>:5:1: error: unknown identifier `foo`"
        r, _ = self.run_loop(["def a := 1"] * 6, err)
        self.assertEqual(r["attempts"], 3)
        self.assertIn("same failure", r["stopped"])

    def test_stop_on(self):
        err = "<generated>:5:1: error: unknown identifier `foo`"
        r, _ = self.run_loop([f"def a{k} := 1" for k in range(6)], err, stop_on=lambda e: "enough")
        self.assertEqual((r["attempts"], r["stopped"]), (1, "enough"))

    def test_oscillation_shows_both_layers(self):
        names = "<generated>:5:1: error: unknown identifier `foo`"
        types = "<generated>:5:1: error: type mismatch\n  x\nhas type Nat"
        text = repair.format_feedback("a\nb\nc\nd\ne", names + "\n" + types, also_stage="types")
        self.assertIn("unknown names or fields and type errors", text)


@unittest.skipUnless(HAS_LEAN, "needs lake")
class WeakFallback(unittest.TestCase):
    def test_weak_spec_kept_when_the_stronger_retries_fail(self):
        """The weak finding is fed back once; if every retry then fails, the weak spec (which
        compiled and passed everything else) is accepted, not dropped."""
        import agents.base as base
        import agents.spec_agent as sa
        from validate import hard_checks
        weak = ITEMS.format(post="o.items = i.items")
        entry = {"kind": "requirement", "text": "The system shall remove items."}
        model = Scripted([weak, "def broken := (", "def broken := (", "def broken := ("])
        with mock.patch.object(base, "call_llm", model), mock.patch.object(base, "MAX_RETRIES", 4), \
                mock.patch.object(sa, "NEGATIVE_CHECK", False):
            r = sa.run_spec("req", "fake", validate=hard_checks(entry), entry=entry)
        self.assertIn("too weak", model.prompts[1])
        self.assertTrue(r["success"])
        self.assertTrue(r["weak_fallback"])
        self.assertEqual(r["code"].strip(), weak.strip())


@unittest.skipUnless(HAS_LEAN, "needs lake")
class NotDecomposable(unittest.TestCase):
    def test_identity_split_falls_back_to_one_component(self):
        import agents.base as base
        import chain_pipeline
        r = {"id": "T-1", "kind": "requirement", "requirement_text": "toy", "lean_predicate": SPEC}
        model = Scripted([IDENTITY])            # L2 of `Spec` is derived by the skeleton: no reply needed
        with mock.patch.object(base, "call_llm", model), mock.patch.object(base, "MAX_RETRIES", 3):
            e = chain_pipeline.run_entry(r, "fake", split="always")
        self.assertEqual(e["l1"]["mode"], "single-not-decomposable")
        self.assertEqual(e["l1"]["failed_split"]["error_class"], "identity")
        self.assertEqual(e["l1"]["attempts"], 2)                         # stopped after 2 identities
        self.assertTrue(e["l1"]["success"])
        self.assertTrue(e["l2"][0]["harness_only"])
        self.assertTrue(e["full_check"])


if __name__ == "__main__":
    unittest.main()
