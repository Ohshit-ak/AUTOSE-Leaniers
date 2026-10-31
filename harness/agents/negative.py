"""Negative-case check for L0 specs: the spec must reject a behaviour the requirement forbids.

Lean only shows a spec compiles and is satisfiable; a `post` that accepts every
output passes both. Here the model names one input (satisfying `pre`) and one
output the *requirement* forbids for it, and Lean must prove `¬ Spec.post IN OUT`.
The model only supplies the two values: the harness writes the statement, so a
reply cannot weaken the claim.

`NegativeCheck` is a validator for `generate_verified`: a spec that accepts the
forbidden output gets a repair problem. An unusable example (wrong fields, input
outside `pre`, API error) never blocks the spec; it is recorded as unknown.
"""
import re
from typing import List, Optional

from agents.base import split_example
from config import NEG_EXAMPLE_ATTEMPTS
from llm import call_llm, extract_lean

NEG_SYSTEM = """\
You test Lean 4 specifications by finding behaviour that the requirement forbids.
Answer with one ```lean block containing exactly these three lines:
  -- why: <which part of the requirement the output breaks>
  IN  := { field := value, … }
  OUT := { field := value, … }
IN is an `Input` and OUT an `Output`, each a named-field record listing EVERY field
(and every field of any helper structure inside them). Write no `example`, `let`,
proof or other Lean. Use only values Lean can evaluate (numbers, strings, lists)."""

NEG_PROMPT = """\
Requirement:
{requirement}

Specification (it compiles):
```lean
{spec}
```

Give one input that satisfies `Spec.pre` and a WRONG output for it: what a buggy
system would return, which the REQUIREMENT does not allow. Use the requirement's
failure case: e.g. for a wrong password, OUT says the user IS signed in; for an
out-of-stock item, OUT says the order WAS placed. Never give the correct output
(e.g. "not signed in" for a wrong password); the correct output is allowed.
Judge OUT by the requirement, not by the spec: if the spec wrongly accepts it,
that is what we want to find."""

_WHY = re.compile(r"^\s*--\s*why:\s*(.+)$", re.MULTILINE)
_DECIDED_FALSE = "proved that the proposition"


def _named_record(code: str, name: str) -> Optional[str]:
    """The record after `IN :=` / `let IN :=` (or `IN : Input :=`), on one line, or None."""
    from validate import _balanced, one_line
    m = re.search(rf"(?<![\w.]){name}\s*(?::\s*\w+\s*)?:=\s*(?=\{{)", code)
    if not m:
        return None
    end = _balanced(code, m.end())
    return one_line(code[m.end():end]) if end else None


def _bad_values(reply: str) -> Optional[tuple]:
    """(input literal, output literal) from the reply, or None.

    Accepts `IN := {…}` / `OUT := {…}` lines (what NEG_SYSTEM asks for), the same with
    `let` (what Qwen wrote in qwen-v6/v7: `let IN := {…}` inside the proof), and
    `Spec.post {…} {…}` written inline.
    """
    from validate import example_witness  # imported here: validate imports agents.base
    code = extract_lean(reply)
    inp, out = _named_record(code, "IN"), _named_record(code, "OUT")
    if inp and out:
        return inp, out
    if not re.search(r"^(example|theorem)\b", code, re.MULTILINE):
        code = "example : " + code
    return example_witness(code)


def judge_bad_example(code: str, reply: str) -> dict:
    """Check the model's forbidden example against `code` in Lean (no model call).

    {status: rejects | accepts_forbidden | bad_example, example, why, error}
      rejects            `pre` holds for IN and Lean proves `¬ Spec.post IN OUT`
      accepts_forbidden  `pre` holds and `decide` proves `Spec.post IN OUT`: the spec is too weak
      bad_example        anything else: the example is unusable, not the spec's fault
    """
    from validate import example_errors
    reply = reply or ""  # some APIs return no text at all
    why = (_WHY.search(reply).group(1).strip() if _WHY.search(reply) else "")
    values = _bad_values(reply)
    if not values:
        return {"status": "bad_example", "example": None, "why": why,
                "error": "no `IN := { … }` and `OUT := { … }` named-field records found"}
    inp, out = values
    pre_ex = f"example : Spec.pre {inp} := by\n  unfold Spec; decide"
    neg_ex = f"example : ¬ Spec.post {inp} {out} := by\n  unfold Spec; decide"
    example = f"example : Spec.pre {inp} ∧ ¬ Spec.post {inp} {out} := by\n  unfold Spec; decide"
    pre_errs, neg_errs = example_errors(split_example(code)[0], [pre_ex, neg_ex])
    if pre_errs:
        error = ("the input does not satisfy `Spec.pre`" if any(_DECIDED_FALSE in e for e in pre_errs)
                 else pre_errs[0])
        return {"status": "bad_example", "example": example, "why": why, "error": error}
    if not neg_errs:
        return {"status": "rejects", "example": example, "why": why, "error": ""}
    if all(_DECIDED_FALSE in e for e in neg_errs):
        return {"status": "accepts_forbidden", "example": example, "why": why, "error": "",
                "input": inp, "output": out}
    return {"status": "bad_example", "example": example, "why": why, "error": neg_errs[0]}


def forbidden_problem(v: dict) -> str:
    """Repair feedback for a spec that accepts the forbidden example `v`."""
    reason = f" ({v['why']})" if v.get("why") else ""
    return (f"your spec accepts a forbidden behaviour: `Spec.post {v['input']} {v['output']}` holds, "
            f"but the requirement forbids this output for this input{reason}. Make `post` say when "
            "the failure outcome happens (with `↔` or `if … then … else`), and put the state that "
            "decides it in `Input`. Do not weaken `pre` to exclude this input.")


class NegativeCheck:
    """Validator: [] if the spec rejects a forbidden example (or none could be found), else a problem.

    `last` is {code, status, example, …} for the most recent spec judged.
    """

    def __init__(self, requirement: str, model: str, attempts: int = NEG_EXAMPLE_ATTEMPTS):
        self.requirement, self.model, self.attempts = requirement, model, attempts
        self.last: Optional[dict] = None
        self._caught: Optional[str] = None  # a reply whose example a previous spec accepted

    def __call__(self, code: str) -> List[str]:
        # A repaired spec must first reject the example that caught its predecessor.
        if self._caught:
            v = judge_bad_example(code, self._caught)
            if v["status"] == "accepts_forbidden":
                self.last = {"code": code, **v}
                return [forbidden_problem(v)]
        ask = NEG_PROMPT.format(requirement=self.requirement, spec=split_example(code)[0])
        v = {"status": "bad_example", "example": None, "error": "not run"}
        for _ in range(self.attempts):
            try:
                reply = call_llm(ask, system=NEG_SYSTEM, model=self.model)
            except Exception as e:  # the check must never fail the entry
                v = {"status": "bad_example", "example": None, "error": f"{type(e).__name__}: {e}"}
                break
            v = judge_bad_example(code, reply)
            if v["status"] != "bad_example":
                break
            ask = (NEG_PROMPT.format(requirement=self.requirement, spec=split_example(code)[0])
                   + f"\n\nYour previous answer could not be used: {v['error']}\n"
                   "Fix it and answer again in the required form.")
        self.last = {"code": code, **v}
        if v["status"] == "accepts_forbidden":
            self._caught = reply
            return [forbidden_problem(v)]
        return []

    def outcome(self, code: str) -> dict:
        """{rejects_bad_example, bad_example} for `code`: True/False, or None if not judged."""
        if not self.last or self.last["code"] != code:
            return {"rejects_bad_example": None, "bad_example": None}
        verdict = {"rejects": True, "accepts_forbidden": False}.get(self.last["status"])
        return {"rejects_bad_example": verdict, "bad_example": self.last.get("example")}
