"""Run from harness/:  python -m unittest discover -s tests

The Lean side of the negative check (agents/negative.py), with fixed model replies.
Needs Lean (`lake`) and a built framework; skipped otherwise.
"""
import shutil
import sys
import unittest
from pathlib import Path

HARNESS = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(HARNESS))

from agents.negative import NegativeCheck, judge_bad_example  # noqa: E402

# The qwen-v3 login spec (runs/0000 - gamma j/qwen-v3): every login succeeds.
ALWAYS_SIGNED_IN = """\
structure Input where
  username : String
  password : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  cookie   : Option Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => o.signedIn = true ∧ o.cookie.isSome = true

example : Spec.pre { username := "salesperson", password := "password123" } ∧
          Spec.post { username := "salesperson", password := "password123" }
                    { signedIn := true, cookie := some 12345 } := by
  unfold Spec; decide
"""

# The login template from the L0 prompt: signed in exactly when the account matches.
ACCOUNT_LOGIN = """\
structure Account where
  username : String
  password : String
  deriving DecidableEq, Repr

structure Input where
  accounts : List Account
  username : String
  password : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => (o.signedIn = true ↔
    ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password)

example : Spec.pre { accounts := [{ username := "sam", password := "pw1" }],
                     username := "sam", password := "pw1" } ∧
          Spec.post { accounts := [{ username := "sam", password := "pw1" }],
                      username := "sam", password := "pw1" }
                    { signedIn := true } := by
  unfold Spec; decide
"""


def reply(inp: str, out: str) -> str:
    return ("```lean\n-- why: a wrong password must not sign the user in\n"
            f"example : Spec.pre {inp} ∧ ¬ Spec.post {inp} {out} := by unfold Spec; decide\n```")


WRONG_PW_OLD = reply('{ username := "salesperson", password := "wrong" }',
                     '{ signedIn := true, cookie := some 1 }')
WRONG_PW_NEW = reply('{ accounts := [{ username := "sam", password := "pw1" }], '
                     'username := "sam", password := "wrong" }', '{ signedIn := true }')


@unittest.skipUnless(shutil.which("lake"), "Lean (lake) not installed")
class TestJudgeBadExample(unittest.TestCase):
    def test_always_signed_in_spec_accepts_forbidden(self):
        v = judge_bad_example(ALWAYS_SIGNED_IN, WRONG_PW_OLD)
        self.assertEqual(v["status"], "accepts_forbidden")

    def test_account_spec_rejects(self):
        v = judge_bad_example(ACCOUNT_LOGIN, WRONG_PW_NEW)
        self.assertEqual(v["status"], "rejects")

    def test_no_records_is_bad_example(self):
        v = judge_bad_example(ACCOUNT_LOGIN, "```lean\nexample : True := trivial\n```")
        self.assertEqual(v["status"], "bad_example")

    def test_unknown_field_is_bad_example(self):
        v = judge_bad_example(ACCOUNT_LOGIN, reply('{ user := "sam" }', '{ signedIn := true }'))
        self.assertEqual(v["status"], "bad_example")

    def test_input_outside_pre_is_bad_example(self):
        v = judge_bad_example(ACCOUNT_LOGIN, reply(
            '{ accounts := [], username := "", password := "x" }', '{ signedIn := true }'))
        self.assertEqual(v["status"], "bad_example")
        self.assertIn("Spec.pre", v["error"])


@unittest.skipUnless(shutil.which("lake"), "Lean (lake) not installed")
class TestNegativeCheckValidator(unittest.TestCase):
    """The validator, with the model call replaced by fixed replies."""

    def check_with(self, replies):
        import agents.negative as neg
        it = iter(replies)
        self.addCleanup(setattr, neg, "call_llm", neg.call_llm)
        neg.call_llm = lambda *a, **k: next(it)
        return NegativeCheck("Login Sales Person", "test", attempts=2)

    def test_problem_for_weak_spec_then_recheck_without_model(self):
        chk = self.check_with([WRONG_PW_OLD])
        problems = chk(ALWAYS_SIGNED_IN)
        self.assertEqual(len(problems), 1)
        self.assertIn("accepts a forbidden behaviour", problems[0])
        self.assertEqual(chk.outcome(ALWAYS_SIGNED_IN)["rejects_bad_example"], False)
        # A repair that is still weak is caught by the remembered example (no more replies left).
        self.assertEqual(len(chk(ALWAYS_SIGNED_IN.replace("password123", "pw"))), 1)

    def test_unusable_examples_do_not_block(self):
        chk = self.check_with(["no code", "still no code"])
        self.assertEqual(chk(ACCOUNT_LOGIN), [])
        self.assertIsNone(chk.outcome(ACCOUNT_LOGIN)["rejects_bad_example"])

    def test_good_spec_passes(self):
        chk = self.check_with([WRONG_PW_NEW])
        self.assertEqual(chk(ACCOUNT_LOGIN), [])
        self.assertEqual(chk.outcome(ACCOUNT_LOGIN)["rejects_bad_example"], True)


if __name__ == "__main__":
    unittest.main()
