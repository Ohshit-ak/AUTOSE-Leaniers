"""L2: one locked contract → implementation + proof of PO3."""
from agents.base import generate_verified

SYSTEM_PROMPT_CODER = """\
You are a coding agent for ContractForge (Lean 4).

Given a Contract (pre/post), implement a function that satisfies it and
prove PO3: `<Name>Contract.Satisfies <name>Impl`.

Rules:
- The spec and contracts are already in scope and LOCKED: do not repeat,
  redefine or modify them, and do not write `import` lines.
- Write `def <name>Impl` and `theorem <name>Impl_ok : <Name>Contract.Satisfies <name>Impl`.
- `Satisfies` and the contract are definitions: try
  `by discharge_po [<Name>Contract, <name>Impl]` first; otherwise
  `unfold Contract.Satisfies <Name>Contract <name>Impl` and prove by hand.
- Use only Lean 4 core functions (no Mathlib).
- No `sorry`. Output ONLY Lean 4 code in one ```lean block.
"""


def run_coder(contract_name: str, locked_code: str, model: str) -> dict:
    prompt = (
        f"Implement the component for `{contract_name}`. Code in scope:\n\n"
        f"```lean\n{locked_code}\n```"
    )
    result = generate_verified(prompt, SYSTEM_PROMPT_CODER, model, context=locked_code)
    return {"name": contract_name, **result}
