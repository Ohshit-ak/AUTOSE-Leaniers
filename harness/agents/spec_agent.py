"""L0: natural-language requirement → Lean spec."""
from agents.base import generate_verified

SYSTEM_PROMPT_SPEC = """\
You are a formal specification agent for Lean 4.

Given a software requirement in English, produce a Lean 4 specification
that captures the requirement precisely.

Rules:
- The framework is already imported and opened; do not write `import` lines.
- Use only Lean core (no Mathlib). For sortedness use `List.Pairwise (· ≤ ·)`,
  for permutations use `List.Perm`.
- Define any data types the system needs.
- Define the spec as `def Spec : Contract Input Output` with `pre` and `post`.
- The spec must be satisfiable: add `example` showing a witness.
- Output ONLY Lean 4 code in one ```lean block.

The Contract structure is:
structure Contract (α β : Type) where
  pre  : α → Prop
  post : α → β → Prop
"""


def run_spec(requirement: str, model: str) -> dict:
    return generate_verified(requirement, SYSTEM_PROMPT_SPEC, model)
