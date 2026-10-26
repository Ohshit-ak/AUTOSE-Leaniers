"""L1: spec → component contracts + proofs of PO1/PO2."""
import re

from agents.base import generate_verified

SYSTEM_PROMPT_ARCHITECT = """\
You are an architecture agent for ContractForge (Lean 4).

Given a system spec `Spec`, decompose it into 2-4 components. For each
component, define a Contract with pre (assumption) and post (guarantee).

Rules:
- The spec code is already in scope; do not repeat it or write `import` lines.
- Name each component contract `def <Name>Contract : Contract A B := ...`.
- Prove PO1: each component's assumption follows from its predecessor's
  guarantee (`Contract.Compatible c₁ c₂`).
- Prove PO2: the composition refines the spec (`Contract.Refines (c₁.seq c₂) Spec`).
- Available: `Contract.Satisfies`, `Contract.Compatible`, `Contract.Refines`,
  `Contract.seq`, theorem `Contract.system_sound`, tactic `discharge_po`.
- No `sorry`. Output ONLY Lean 4 code in one ```lean block.
"""

_CONTRACT_DEF = re.compile(r"^def\s+(\w+Contract)\b", re.MULTILINE)


def run_architect(spec_code: str, model: str) -> dict:
    prompt = f"Decompose this spec into contracts and prove PO1+PO2:\n\n```lean\n{spec_code}\n```"
    return generate_verified(prompt, SYSTEM_PROMPT_ARCHITECT, model, context=spec_code)


def extract_contracts(arch_code: str) -> list[str]:
    """Names of the component contracts defined by the architect."""
    return _CONTRACT_DEF.findall(arch_code)
