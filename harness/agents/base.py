"""Shared generate → check → repair loop used by every agent."""
from config import MAX_RETRIES
from lean_runner import check_lean
from llm import call_llm, extract_lean


def generate_verified(prompt: str, system: str, model: str, context: str = "") -> dict:
    """Ask the model for Lean code, retrying with Lean's errors until it checks.

    `context` is already-verified Lean (e.g. a locked spec/contract) that is
    prepended when checking but never shown as editable to the model.
    """
    code = extract_lean(call_llm(prompt, system=system, model=model))
    for attempt in range(1, MAX_RETRIES + 1):
        result = check_lean(f"{context}\n\n{code}" if context else code)
        if result["success"]:
            return {"success": True, "code": code, "attempts": attempt}
        if attempt == MAX_RETRIES:
            break
        repair = (
            f"{prompt}\n\nYour previous attempt failed to check.\n\n"
            f"Code:\n```lean\n{code}\n```\n\nLean error:\n{result['error']}\n\n"
            "Return the full corrected code."
        )
        code = extract_lean(call_llm(repair, system=system, model=model))
    return {"success": False, "code": code, "attempts": MAX_RETRIES, "error": result["error"]}
