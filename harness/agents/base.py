"""Shared generate → check → repair loop used by every agent."""
import re
from typing import Callable, List, Optional

from agents.fixups import apply_fixups
from agents.repair import earliest_stage, error_signature, format_feedback, parse_errors
from config import MAX_RETRIES, RESTART_TEMPERATURE, TEMPERATURE
from lean_runner import HEADER, check_lean
from llm import call_llm, extract_lean

REPAIR_RULES = """

When fixing code that failed to check:
- Fix exactly the errors reported; keep everything that already worked.
- Never weaken the specification to make errors go away: do not delete conditions,
  and do not replace `pre`/`post` with `True`.
- Keep the names `Input`, `Output` and `Spec` (or the names you were asked for).
- Follow the "How to fix" hints; they come from the Lean errors.
- Return the COMPLETE corrected file in one ```lean block, not only the changed lines."""

HISTORY_TURNS = 2       # earlier (code, errors) exchanges kept in the conversation
VALUE_ATTEMPTS = 2      # example-only repairs before the definitions are unlocked again

_EXAMPLE_START = re.compile(r"^(example|theorem)\b", re.MULTILINE)
_TRIVIAL_PRE = re.compile(r"\bpre\s*:=\s*fun\s+[\w_]+\s*=>\s*[Tt]rue\s*$", re.MULTILINE)
_TRIVIAL_POST = re.compile(r"\bpost\s*:=\s*fun\s+[\w_]+\s+[\w_]+\s*=>\s*[Tt]rue\s*$", re.MULTILINE)

# validate(code) → list of problems; empty means the code is accepted.
Validator = Callable[[str], List[str]]


def split_example(code: str):
    """(definitions, example part) — the example part starts at the first `example`/`theorem`."""
    m = _EXAMPLE_START.search(code)
    return (code[:m.start()].rstrip(), code[m.start():].strip()) if m else (code, "")


def _output_refs(code: str) -> int:
    """How many different `o.<field>` the code mentions (0 = `post` ignores the output)."""
    return len(set(re.findall(r"\bo\.(\w+)", code)))


def weakened(original: str, candidate: str) -> Optional[str]:
    """Why `candidate` says less than `original`, or None. Only clear-cut cases count."""
    if _TRIVIAL_PRE.search(candidate) and not _TRIVIAL_PRE.search(original):
        return "`pre` was replaced by `True`"
    if _TRIVIAL_POST.search(candidate) and not _TRIVIAL_POST.search(original):
        return "`post` was replaced by `True`"
    if _output_refs(original) and not _output_refs(candidate):
        return "`post` no longer says anything about the output `o`"
    return None


def _errors_only_in_example(code: str, error: str, context: str) -> bool:
    defs, example = split_example(code)
    if not example:
        return False
    offset = HEADER.count("\n") + ((context.count("\n") + 2) if context else 0)
    first_example_line = defs.count("\n") + 2
    lines = [e["line"] - offset for e in parse_errors(error)]
    return bool(lines) and all(n >= first_example_line for n in lines)


def _too_long(e: Exception) -> bool:
    text = str(e).lower()
    return "context" in text and ("exceed" in text or "too long" in text or "maximum" in text)


def _ask(prompt: str, system: str, model: str, history=None, temperature=TEMPERATURE) -> str:
    """call_llm, but a conversation that no longer fits the model's context is retried
    without its history instead of failing the entry."""
    try:
        return call_llm(prompt, system=system, model=model, history=history, temperature=temperature)
    except Exception as e:
        if history and _too_long(e):
            return call_llm(prompt, system=system, model=model, temperature=temperature)
        raise


def generate_verified(prompt: str, system: str, model: str, context: str = "",
                      validate: Optional[Validator] = None,
                      find_witness: Optional[Callable[[str], Optional[str]]] = None) -> dict:
    """Ask the model for Lean code, retrying with Lean's errors until it checks.

    `context` is already-verified Lean (e.g. a locked spec/contract) that is
    prepended when checking but never shown as editable to the model.
    `validate` runs after Lean accepts the code (e.g. the L0.5 checks); its
    problems are fed back like Lean errors. `find_witness(code)` returns an
    `example` with values the harness found itself, or None.

    Each attempt:
      1. mechanical syntax fixes (agents/fixups.py) are applied;
      2. a repair that weakens the code (see `weakened`) is rejected without checking;
      3. Lean errors are fed back one layer at a time (syntax → names → types → proof);
      4. if only the `example` is wrong, the harness first searches for values
         itself (`find_witness`); if none exist the spec is likely contradictory and
         the model is told to fix the spec. Otherwise the definitions are locked and
         the model writes just a new example (at most VALUE_ATTEMPTS times in a row);
      5. if the same error comes back twice, the model starts over at a higher temperature.
    """
    system = system + REPAIR_RULES
    code = extract_lean(call_llm(prompt, system=system, model=model))
    original, history, last_sig = None, [], None
    locked_defs, value_tries = None, 0
    searched: set = set()  # definitions the witness search already ran on
    log: List[dict] = []
    result = {"error": ""}

    for attempt in range(1, MAX_RETRIES + 1):
        code, fixes = apply_fixups(code)
        if locked_defs is not None:
            _, example = split_example(code)
            code = f"{locked_defs}\n\n{example or code}"
        if original is None:
            original = code

        why = weakened(original, code)
        if why:
            stage, feedback_body = "weakened", (
                f"Your last change weakened the specification: {why}. Restore the original "
                "meaning and fix only the reported errors.")
            result = {"success": False, "error": f"rejected: {why}"}
        else:
            result = check_lean(f"{context}\n\n{code}" if context else code)
            problems = validate(code) if result["success"] and validate else []
            if result["success"] and not problems:
                log.append({"attempt": attempt, "stage": "ok", "fixups": fixes})
                return {"success": True, "code": code, "attempts": attempt, "log": log}
            if result["success"]:
                stage = "check"
                result = {"success": False, "error": "L0.5: " + "; ".join(problems)}
                feedback_body = ("Lean accepts the code, but the specification checks found "
                                 "problems:\n" + "\n".join(f"- {p}" for p in problems))
            else:
                stage = earliest_stage(result["error"]) or "other"
                feedback_body = format_feedback(code, result["error"], context)
                if "proved that the proposition" in result["error"] and not context:
                    from validate import false_conjuncts  # imported here: validate imports this module
                    broken = false_conjuncts(code)
                    if broken:
                        feedback_body += ("\n\nWith your example values, these conditions are false:\n"
                                          + "\n".join(f"- {b}" for b in broken)
                                          + "\nChange the example values so that every condition holds.")
        log.append({"attempt": attempt, "stage": stage, "fixups": fixes})
        if attempt == MAX_RETRIES:
            break

        only_example = stage == "proof" and _errors_only_in_example(code, result["error"], context)
        # Only the example is wrong: let the harness look for values first.
        if only_example and find_witness and not context:
            defs, _ = split_example(code)
            if defs not in searched:
                searched.add(defs)
                found = find_witness(code)
                if found:
                    log[-1]["witness"] = "found by search"
                    code, locked_defs = f"{defs}\n\n{found}", None
                    continue
                log[-1]["witness"] = "none found"
                feedback_body += ("\n\nThe harness also tried hundreds of value combinations and "
                                  "none satisfies `pre` and `post` together, so the definitions are "
                                  "probably contradictory. Fix `pre`/`post` (without weakening them "
                                  "to `True`) so that some input and output satisfy them.")
                value_tries = VALUE_ATTEMPTS  # go straight to a full repair
        # Only the example is wrong: lock the definitions and ask for new values.
        if only_example and value_tries < VALUE_ATTEMPTS:
            locked_defs, _ = split_example(code)
            value_tries += 1
            ask = (f"{prompt}\n\nThese definitions are fixed and compile; do not change them:\n"
                   f"```lean\n{locked_defs}\n```\n\n{feedback_body}\n\n"
                   "Write ONLY a new `example` (one ```lean block) whose values satisfy `pre` "
                   "and `post`, proved `by unfold Spec; decide`.")
            temp = RESTART_TEMPERATURE if value_tries > 1 else TEMPERATURE
            code = extract_lean(_ask(ask, system, model, temperature=temp))
            continue
        locked_defs, value_tries = None, 0

        sig = error_signature(result["error"])
        if sig == last_sig:
            history, last_sig = [], None
            code = extract_lean(_ask(prompt, system, model, temperature=RESTART_TEMPERATURE))
            continue
        last_sig = sig
        if not history:
            history = [{"role": "user", "content": prompt}]
        history.append({"role": "assistant", "content": f"```lean\n{code}\n```"})
        feedback = f"{feedback_body}\n\nReturn the full corrected code."
        reply = _ask(feedback, system, model, history=history)
        history.append({"role": "user", "content": feedback})
        # keep the original request plus the last HISTORY_TURNS exchanges
        history = history[:1] + history[1:][-2 * HISTORY_TURNS:]
        code = extract_lean(reply)
    return {"success": False, "code": code, "attempts": MAX_RETRIES,
            "error": result["error"], "log": log}
