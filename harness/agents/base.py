"""Shared generate → check → repair loop used by every agent."""
import re
from typing import Callable, List, Optional

from agents.fixups import apply_fixups
from agents.repair import STAGES, earliest_stage, error_signature, format_feedback, parse_errors
from config import MAX_RETRIES, RESTART_TEMPERATURE, TEMPERATURE
from lean_runner import HEADER, check_lean
from llm import Truncated, call_llm, extract_lean

REPAIR_RULES = """

When fixing code that failed to check:
- Fix exactly the errors reported; keep everything that already worked.
- Never weaken the specification to make errors go away: do not delete conditions,
  and do not replace `pre`/`post` with `True`.
- Keep the names `Input`, `Output` and `Spec` (or the names you were asked for).
- Follow the "How to fix" hints; they come from the Lean errors.
- Return the COMPLETE corrected file in one ```lean block, not only the changed lines.
  Code that was given to you as already in scope is NOT part of your file: never repeat it."""

HISTORY_TURNS = 2       # earlier (code, errors) exchanges kept in the conversation
EARLY_STOP_SAME = 3     # v11: the same failure, word for word, this many times → give up
VALUE_ATTEMPTS = 2      # example-only repairs before the definitions are unlocked again

_EXAMPLE_START = re.compile(r"^(example|theorem)\b", re.MULTILINE)
_TRIVIAL_PRE = re.compile(r"\bpre\s*:=\s*fun\s+[\w_]+\s*=>\s*[Tt]rue\s*$", re.MULTILINE)
_TRIVIAL_POST = re.compile(r"\bpost\s*:=\s*fun\s+[\w_]+\s+[\w_]+\s*=>\s*[Tt]rue\s*$", re.MULTILINE)

# validate(code) → list of problems; empty means the code is accepted.
Validator = Callable[[str], List[str]]


_TOP_DECL = re.compile(r"^(?:@\[[^\]]*\]\s*)?(?:noncomputable\s+)?(?:private\s+)?"
                       r"(?:def|structure|inductive|abbrev|theorem|lemma|instance|class)\s+([\w.]+)", re.M)


def strip_redeclared(code: str, context: str) -> tuple:
    """Remove top-level declarations in `code` whose names are already declared in `context`.

    The checked file is `context + code`, so a repeated declaration can never compile
    ("already been declared"); the copy in `context` is the locked one. Returns
    (code, removed names). A declaration runs until the next non-indented line.
    """
    locked = set(_TOP_DECL.findall(context)) if context else set()
    if not locked:
        return code, []
    out, removed, skipping = [], [], False
    for line in code.split("\n"):
        top = line[:1] not in ("", " ", "\t")
        if top:
            m = _TOP_DECL.match(line)
            skipping = bool(m and m.group(1) in locked)
            if skipping:
                removed.append(m.group(1))
        if not skipping:
            out.append(line)
    return "\n".join(out).strip(), removed


def split_example(code: str):
    """(definitions, example part) — the example part starts at the first `example`/`theorem`."""
    m = _EXAMPLE_START.search(code)
    return (code[:m.start()].rstrip(), code[m.start():].strip()) if m else (code, "")


def with_locked_defs(locked_defs: str, reply: str, fallback_example: str) -> str:
    """The locked definitions plus the `example` from `reply`.

    The model was asked for only an `example`. If it sent none, keep the previous
    example instead of appending the whole reply, which would declare
    `Input`/`Output`/`Spec` a second time.
    """
    _, example = split_example(reply)
    return f"{locked_defs}\n\n{example or fallback_example}".rstrip()


# How far an attempt got: higher is better. Used to return the best attempt, not the last.
RANK_NOT_CHECKED, RANK_LEAN_ERROR, RANK_COMPILES = 0, 1, 2


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


def _exact_signature(error: str) -> str:
    """The failure word for word, without positions and file paths (for the early stop)."""
    text = re.sub(r"<generated>:\d+:\d+", "", error or "")
    return " ".join(text.split())[:2000]


def _too_long(e: Exception) -> bool:
    text = str(e).lower()
    return "context" in text and ("exceed" in text or "too long" in text or "maximum" in text)


# Stands in for the code of an attempt whose reply was cut off (llm.Truncated).
TRUNCATED = "-- (reply cut off: truncated)"
TRUNCATED_NOTE = ("Your previous answer was cut off before it ended because it was too long. "
                  "Answer again with ONE short ```lean block and no explanation. Never repeat a "
                  "pattern (e.g. `.1.2.3.4…`); write each condition once.")


def _ask(prompt: str, system: str, model: str, history=None, temperature=TEMPERATURE) -> str:
    """call_llm, but a conversation that no longer fits the model's context is retried
    without its history instead of failing the entry, and a reply that is cut off
    (even after llm's retry with more tokens) comes back as TRUNCATED."""
    try:
        return call_llm(prompt, system=system, model=model, history=history, temperature=temperature)
    except Truncated:
        return TRUNCATED
    except Exception as e:
        if history and _too_long(e):
            try:
                return call_llm(prompt, system=system, model=model, temperature=temperature)
            except Truncated:
                return TRUNCATED
        raise


def generate_verified(prompt: str, system: str, model: str, context: str = "",
                      validate: Optional[Validator] = None,
                      find_witness: Optional[Callable[[str], Optional[str]]] = None,
                      auto_prove: Optional[Callable[[str, str], Optional[str]]] = None,
                      prepare: Optional[Callable[[str], str]] = None,
                      precheck: Optional[Validator] = None,
                      check_weakened: bool = True, check_label: str = "L0.5",
                      strategy_hint: Optional[Callable[[str, str], Optional[str]]] = None,
                      stop_on: Optional[Callable[[str], Optional[str]]] = None) -> dict:
    """Ask the model for Lean code, retrying with Lean's errors until it checks.

    `context` is already-verified Lean (e.g. a locked spec/contract) that is
    prepended when checking but never shown as editable to the model.
    `validate` runs after Lean accepts the code (e.g. the L0.5 checks); its
    problems are fed back like Lean errors. `find_witness(code)` returns an
    `example` with values the harness found itself, or None.
    `prepare(code)` rewrites each reply before anything else looks at it (e.g. drops the
    theorems when the harness states and proves them itself). `precheck(code)` runs before
    Lean: its problems are fed back without a Lean run (stage `static`), so a mistake the
    harness can name (a field the contract cannot see) is not reported as a raw Lean error.
    `check_weakened=False` turns off the L0 rule that `pre`/`post` may not become `True`:
    for a component contract, dropping an assumption is a legitimate repair.

    Each attempt:
      1. mechanical syntax fixes (agents/fixups.py) are applied;
      2. a repair that weakens the code (see `weakened`) is rejected without checking;
      3. Lean errors are fed back one layer at a time (syntax → names → types → proof);
      4. if only the `example` is wrong, the harness first searches for values
         itself (`find_witness`); if none exist the spec is likely contradictory and
         the model is told to fix the spec. Otherwise the definitions are locked and
         the model writes just a new example (at most VALUE_ATTEMPTS times in a row);
      5. (v11) when the same check fails again the strategy changes instead of repeating:
         2nd time in a row → fresh prompt without history at a higher temperature;
         3rd → fresh prompt plus `strategy_hint(code, error)` (e.g. the L2 skeleton built
         from the contract), or a plain fresh prompt if there is none; 4th → stop.
         The same failure, word for word, 3 times (not necessarily in a row) → stop.
         `stop_on(error)` returns a reason to stop at once (e.g. L1: the split is an identity
         twice, so the spec is not decomposable). When Lean's error layers swing back
         (names → types → names), both layers are shown in one feedback.
    """
    system = system + REPAIR_RULES
    code = extract_lean(_ask(prompt, system, model))
    original, history, last_sig = None, [], None
    locked_defs, locked_example, value_tries = None, "", 0
    searched: set = set()  # definitions the witness search already ran on
    log: List[dict] = []
    result = {"error": ""}
    best = None  # (rank, attempt, code, error) of the furthest-reaching attempt
    same_check, seen_errors, stages = 0, {}, []   # v11 strategy ladder / early stop / oscillation
    stopped, hint_used = None, False

    for attempt in range(1, MAX_RETRIES + 1):
        if code == TRUNCATED:  # never sent to Lean: start over with a request to be brief
            log.append({"attempt": attempt, "stage": "truncated", "fixups": []})
            result = {"success": False, "error": "truncated: the reply was cut off at the token limit"}
            if best is None:
                best = (RANK_NOT_CHECKED - 1, attempt, "", result["error"])
            if attempt == MAX_RETRIES:
                break
            history, last_sig, locked_defs, value_tries = [], None, None, 0
            code = extract_lean(_ask(f"{prompt}\n\n{TRUNCATED_NOTE}", system, model,
                                     temperature=RESTART_TEMPERATURE))
            continue
        code, fixes = apply_fixups(code)
        code, dropped = strip_redeclared(code, context)
        if dropped:
            fixes = list(fixes) + [f"dropped re-declared locked names {sorted(set(dropped))}"]
        if prepare:
            code = prepare(code)
        if locked_defs is not None:
            code = with_locked_defs(locked_defs, code, locked_example)
        if original is None:
            original = code

        why = weakened(original, code) if check_weakened else None
        static = precheck(code) if precheck and not why else []
        if static:
            stage, feedback_body = "static", (
                "The code was not sent to Lean because of these problems:\n"
                + "\n".join(f"- {p}" for p in static))
            result = {"success": False, "error": "static: " + "; ".join(static)}
        elif why:
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
                result = {"success": False, "error": f"{check_label}: " + "; ".join(problems)}
                feedback_body = ("Lean accepts the code, but the specification checks found "
                                 "problems:\n" + "\n".join(f"- {p}" for p in problems))
            else:
                stage = earliest_stage(result["error"]) or "other"
                # names → types → names: show both layers instead of only the earliest
                swing = (stages[-1] if len(stages) >= 2 and stages[-2] == stage and stages[-1] != stage
                         and stages[-1] in STAGES else None)
                feedback_body = format_feedback(code, result["error"], context, also_stage=swing)
                # Lean failed, so `validate` did not run; an always-false equation is
                # worth reporting anyway (the example can never be proved with it).
                from validate import check_contradictions  # imported here: validate imports this module
                impossible = check_contradictions(code)
                if impossible:
                    feedback_body += "\n\n" + "\n".join(f"- {p}" for p in impossible)
                if "proved that the proposition" in result["error"] and not context:
                    from validate import false_conjuncts  # imported here: validate imports this module
                    broken = false_conjuncts(code)
                    if broken:
                        feedback_body += ("\n\nWith your example values, these conditions are false:\n"
                                          + "\n".join(f"- {b}" for b in broken)
                                          + "\nChange the example values so that every condition holds.")
        log.append({"attempt": attempt, "stage": stage, "fixups": fixes})
        stages.append(stage)
        rank = {"weakened": RANK_NOT_CHECKED, "static": RANK_NOT_CHECKED,
                "check": RANK_COMPILES}.get(stage, RANK_LEAN_ERROR)
        if best is None or rank > best[0]:  # ties keep the earlier attempt
            best = (rank, attempt, code, result["error"])
        exact = _exact_signature(result["error"])
        seen_errors[exact] = seen_errors.get(exact, 0) + 1
        # the skeleton/hint strategy is always tried once before giving up on repeats
        repeat_stop = seen_errors[exact] >= EARLY_STOP_SAME and (strategy_hint is None or hint_used)
        stopped = (stop_on(result["error"]) if stop_on else None) or (
            f"the same failure {EARLY_STOP_SAME} times" if repeat_stop else None)
        if stopped:
            log[-1]["stopped"] = stopped
            break
        if attempt == MAX_RETRIES:
            break

        # The example-only repair is for L0 specs (`example … unfold Spec; decide`). With a
        # locked context (L1/L2) the trailing part is PO theorems, not an example.
        # L1/L2: definitions compile, only the PO theorems fail → try generic proofs first.
        # Not gated on the error class (proof errors are often reported as type errors):
        # auto_prove itself first checks that the definitions compile without the theorems.
        if auto_prove and context and stage not in ("weakened", "check", "static"):
            proved = auto_prove(code, context)
            if proved and not (validate and validate(proved)):
                log[-1]["autoprove"] = "proved by search"
                log.append({"attempt": attempt, "stage": "ok", "fixups": fixes + ["autoprove"]})
                return {"success": True, "code": proved, "attempts": attempt, "log": log}
            log[-1]["autoprove"] = "none found"
        # The example-only repair is for L0 specs (`example … unfold Spec; decide`). With a
        # locked context (L1/L2) the trailing part is PO theorems, not an example.
        only_example = (not context and stage == "proof"
                        and _errors_only_in_example(code, result["error"], context))
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
            locked_defs, locked_example = split_example(code)
            value_tries += 1
            ask = (f"{prompt}\n\nThese definitions are fixed and compile; do not change them:\n"
                   f"```lean\n{locked_defs}\n```\n\n{feedback_body}\n\n"
                   "Write ONLY a new `example` (one ```lean block) whose values satisfy `pre` "
                   "and `post`, proved `by unfold Spec; decide`.")
            temp = RESTART_TEMPERATURE if value_tries > 1 else TEMPERATURE
            code = extract_lean(_ask(ask, system, model, temperature=temp))
            continue
        locked_defs, value_tries = None, 0

        sig = (stage, error_signature(result["error"]))
        same_check = same_check + 1 if sig == last_sig else 1
        last_sig = sig
        if same_check >= 4:
            stopped = "the same check failed 4 times in a row"
            log[-1]["stopped"] = stopped
            break
        if seen_errors[exact] >= EARLY_STOP_SAME and strategy_hint and not hint_used:
            same_check = max(same_check, 3)   # repeats word for word: go straight to the hint
        if same_check >= 2:   # change strategy, do not repeat the same repair
            history = []
            extra = strategy_hint(code, result["error"]) if (strategy_hint and same_check == 3) else None
            hint_used = hint_used or same_check == 3
            log[-1]["strategy"] = "fresh+hint" if extra else "fresh"
            ask = f"{prompt}\n\n{extra}" if extra else prompt
            code = extract_lean(_ask(ask, system, model, temperature=RESTART_TEMPERATURE))
            continue
        if not history:
            history = [{"role": "user", "content": prompt}]
        history.append({"role": "assistant", "content": f"```lean\n{code}\n```"})
        feedback = f"{feedback_body}\n\nReturn the full corrected code." + (
            " Do not repeat the code that is already in scope." if context else "")
        reply = _ask(feedback, system, model, history=history)
        history.append({"role": "user", "content": feedback})
        # keep the original request plus the last HISTORY_TURNS exchanges
        history = history[:1] + history[1:][-2 * HISTORY_TURNS:]
        code = extract_lean(reply)
    # Out of retries: return the attempt that got furthest (e.g. one that compiled but
    # failed L0.5), not whatever the last repair produced.
    _, best_attempt, best_code, best_error = best
    log.append({"attempt": best_attempt, "stage": "returned"})
    out = {"success": False, "code": best_code, "attempts": attempt,
           "error": best_error, "log": log}
    if stopped:
        out["stopped"] = stopped
    return out
