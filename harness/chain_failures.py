"""Why an L1 architecture or an L2 implementation of the chain path failed (no model).

`classify(error, stages)` maps the error text an agent returned to one class, so failures can
be counted (`evaluation/summarize_e2e.py`) instead of read one by one. The classes:

    harness checks (chain_checks / chain_coder, named by the harness)
        shape          not two contracts, or the types do not chain Input → Mid → Output
        visibility     a contract reads a field its records do not have (e.g. an Input
                       field in the second contract)
        identity       a component only copies fields / is `Spec` again / computes a result
                       that is constant or a disguised copy
        unrealizable   the first contract promises a fact about its input
        po1 / po2      the obligation does not hold; the message names the conjunct
        signature      the implementation has the wrong name or type
        unknown-field  the record an implementation returns does not have the fields of
                       its result structure
        po3            the implementation does not establish the contract
        forbidden      `sorry`, `axiom`, …
    Lean errors (older runs, or code that does not compile)
        redeclared     a locked name declared again
        unknown-field, unknown-name, syntax, type-error, proof
    other
        truncated, timeout, crash, unknown

`root_cause(entry)` looks at an accepted architecture whose implementation failed and says
whether the contract could be implemented at all.
"""
import re
from typing import List, Optional

from agents.repair import error_stage, parse_errors

_RULES = [
    ("forbidden", r"is not allowed"),
    ("shape", r"exactly two contracts|types must chain|declare `structure"),
    ("signature", r"exactly this signature|has type `[^`]*`, but `|must be a term"),
    ("unknown-field", r"does not match `structure "),
    ("visibility", r"has no field `|is not one of its variables"),
    ("identity", r"is an identity|is `Spec` again|never reads what|computes nothing"),
    ("unrealizable", r"cannot guarantee `"),
    ("po1", r"PO1 fails"),
    ("po2", r"PO2 fails|PO2 could not be proved"),
    ("po3", r"PO3 fails|PO3 could not be proved|PO3 must be stated"),
]
_LEAN = [
    ("redeclared", r"has already been declared"),
    ("unknown-field", r"Invalid field|is not a field of structure|does not contain `"),
    ("unknown-name", r"[Uu]nknown (identifier|constant|namespace)"),
]
CLASSES = list(dict.fromkeys([c for c, _ in _RULES] + [c for c, _ in _LEAN] + [
    "syntax", "type-error", "proof", "truncated", "timeout", "crash", "unknown"]))


def classify(error: Optional[str], stages: Optional[List[str]] = None) -> Optional[str]:
    """The failure class of `error`, or None for no error."""
    if not error:
        return None
    if error.startswith("truncated"):
        return "truncated"
    if "timed out" in error:
        return "timeout"
    if re.match(r"(static|L1|L2|L0\.5): ", error):
        # Harness message. Several problems may be listed: the first rule that matches wins,
        # in the order a person would fix them (shape before visibility before work …).
        for name, rx in _RULES:
            if re.search(rx, error):
                return name
        return "unknown"
    errs = parse_errors(error)
    if not errs:
        return "crash" if "Traceback" in error or "Error:" in error else "unknown"
    msg = errs[0]["msg"]
    for name, rx in _LEAN:
        if re.search(rx, msg):
            return name
    return {"syntax": "syntax", "names": "unknown-name", "types": "type-error", "proof": "proof"}[error_stage(msg)]


def root_cause(entry: dict) -> Optional[str]:
    """For an entry whose L1 passed and some L2 failed: was the failing contract implementable?

    Uses the architecture's own text (chain_checks): a first contract that states a fact about
    fields it only copies from `Input` cannot be implemented for every input, whatever the
    coder writes; neither can one whose `Mid` fields are not related to `Input` when the
    second contract's `pre` needs them. Returns a short reason or None (no structural cause)."""
    import chain_checks as C
    l1 = entry.get("l1") or {}
    failed = [x["contract"] for x in entry.get("l2", []) if not x.get("success")]
    if not l1.get("success") or not failed or l1.get("mode", "chain") != "chain":
        return None
    cs = [c for c in C.parse_contracts(l1.get("code") or "") if c.name != "Spec"]
    for x in entry.get("l2", []):   # an implementation written in the wrong direction
        c = next((c for c in cs if c.name == x["contract"]), None)
        if c and not x.get("success") and re.search(
                rf"^def\s+{re.escape(c.name)}Impl\s*\([^)]*:\s*{re.escape(c.cod)}\s*\)\s*:\s*{re.escape(c.dom)}\b",
                x.get("code") or "", re.MULTILINE):
            return (f"implementation written backwards: `{c.name}Impl : {c.cod} → {c.dom}` for "
                    f"`{c.name} : Contract {c.dom} {c.cod}`")
    if len(cs) != 2:
        return None
    a = cs[0] if cs[0].dom == "Input" else cs[1]
    if a.name not in failed:
        return None
    carried = {}
    for c in C.conjuncts(a.post):
        cp = C._copy(c, a.out_var, a.in_var)
        if cp:
            carried[cp[0]] = cp[1]
    pre = {C.canon(c, [a.pre_var]) for c in C.conjuncts(a.pre)}
    for c in C.conjuncts(a.post):
        if C._copy(c, a.out_var, a.in_var) or not C._mentions(c, a.out_var):
            continue
        on_input = c
        for mf, inf in carried.items():
            on_input = re.sub(rf"(?<![\w.']){re.escape(a.out_var)}\.{re.escape(mf)}(?![\w'])",
                              f"{a.in_var}.{inf}", on_input)
        if not C._mentions(on_input, a.out_var) and C.canon(on_input, [a.in_var]) not in pre:
            return f"contract not implementable: `{a.name}` promises `{c}` about a field it copies from the input"
    return None
