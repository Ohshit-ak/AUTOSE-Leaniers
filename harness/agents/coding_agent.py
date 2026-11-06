"""L2: one locked contract → implementation + proof of PO3."""
import re

from agents.autoprove import auto_prove
from agents.base import generate_verified

SYSTEM_PROMPT_CODER = """\
You are a coding agent for ContractForge (Lean 4).

Given ONE component contract `C : Contract A B`, implement a plain function
`def <C>Impl (x : A) : B` and prove PO3: `<C>.Satisfies <C>Impl`.

Rules:
- The spec and all contracts are already in scope and LOCKED: never repeat,
  redefine or modify them (no `structure`, no `def ...Contract`, no `def Spec`),
  no `example`, no `import` lines.
- Implement ONLY the contract you are asked for, not the other components.
- The implementation is an ordinary term (`:= { field := ... }`, `if … then … else`,
  list functions), never a tactic block (`:= by ...`). Lean 4 core only, no Mathlib.
- The theorem must be exactly `theorem <C>Impl_ok : <C>.Satisfies <C>Impl`.
- Proof: try `by discharge_po [<C>, <C>Impl]`; otherwise
  `unfold Contract.Satisfies <C> <C>Impl` and prove by hand (intro, simp_all, omega).
- No `sorry`. Output ONLY Lean 4 code in one ```lean block.

Example, for `ComputeContract : Contract Mid Output` with
`post := fun m o => o.total = m.price * m.qty`:
```lean
def ComputeContractImpl (m : Mid) : Output := { total := m.price * m.qty }

theorem ComputeContractImpl_ok : ComputeContract.Satisfies ComputeContractImpl := by
  discharge_po [ComputeContract, ComputeContractImpl]
```
"""


def run_coder(contract_name: str, locked_code: str, model: str) -> dict:
    prompt = (
        f"Code already in scope (LOCKED, do not repeat it):\n\n{locked_code}\n\n"
        f"Implement ONLY `{contract_name}`: write `def {contract_name}Impl` and "
        f"`theorem {contract_name}Impl_ok : {contract_name}.Satisfies {contract_name}Impl`."
    )
    def validate(code: str) -> list:
        if not re.search(rf"\b{re.escape(contract_name)}\.Satisfies\b|Contract\.Satisfies\s+{re.escape(contract_name)}\b", code):
            return [f"PO3 must be stated for this contract: "
                    f"`theorem {contract_name}Impl_ok : {contract_name}.Satisfies {contract_name}Impl`"]
        return []

    result = generate_verified(prompt, SYSTEM_PROMPT_CODER, model, context=locked_code, validate=validate,
                              auto_prove=auto_prove)
    return {"name": contract_name, **result}
