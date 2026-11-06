"""L1: spec → component contracts + proofs of PO1/PO2."""
import re

from agents.base import generate_verified

SYSTEM_PROMPT_ARCHITECT = """\
You are an architecture agent for ContractForge (Lean 4).

Given a system spec `Spec : Contract Input Output`, split it into EXACTLY TWO
components that run one after the other, and prove that they are compatible
(PO1) and that together they refine the spec (PO2).

Rules:
- `Input`, `Output` and `Spec` are already in scope and LOCKED: never write
  `structure Input`, `structure Output` or `def Spec` again. No `import` lines.
- Declare one new intermediate structure (e.g. `Mid`) for the data passed
  between the components, with `deriving DecidableEq, Repr`.
- The types must chain: `def <A>Contract : Contract Input Mid` and
  `def <B>Contract : Contract Mid Output`. Never use `Spec` as a component and
  never give both components the type `Contract Input Output`.
- Each component must do real work: do not make one of them a copy of `Spec`
  and the other an identity that only passes `Input` through.
- PO1: `theorem po1 : Contract.Compatible <A>Contract <B>Contract`.
- PO2: `theorem po2 : Contract.Refines (<A>Contract.seq <B>Contract) Spec`.
- Proofs: `Compatible`, `Refines` and your contracts are definitions, so unfold
  them first. Try `by discharge_po [<A>Contract, <B>Contract, Spec]`; if that
  fails, `unfold Contract.Compatible ...` / `unfold Contract.Refines Contract.seq ...`
  and prove by hand as below. Do not write `simp [Spec.pre]` (that is not a lemma).
- No `sorry`, no `example`. Output ONLY Lean 4 code in one ```lean block.

Worked example. In scope:
  structure Input where price : Nat; qty : Nat
  structure Output where total : Nat
  def Spec : Contract Input Output where
    pre  := fun i => i.qty > 0
    post := fun i o => o.total = i.price * i.qty
Your answer:
```lean
structure Mid where
  price : Nat
  qty   : Nat
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.qty > 0
  post := fun i m => m.price = i.price ∧ m.qty = i.qty ∧ m.qty > 0

def ComputeContract : Contract Mid Output where
  pre  := fun m => m.qty > 0
  post := fun m o => o.total = m.price * m.qty

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  unfold Contract.Compatible ValidateContract ComputeContract
  intro i m _ h
  exact h.2.2

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  unfold Contract.Refines Contract.seq ValidateContract ComputeContract Spec
  refine ⟨fun i h => h, ?_⟩
  intro i o _ ⟨m, ⟨hp, hq, _⟩, ho⟩
  simp only at *
  rw [ho, hp, hq]
```
"""

_CONTRACT_DEF = re.compile(r"^def\s+(\w+Contract)\b", re.MULTILINE)


def run_architect(spec_code: str, model: str) -> dict:
    prompt = (f"These definitions are already in scope (LOCKED, do not repeat them):\n\n{spec_code}\n\n"
              "Split `Spec` into exactly two chained component contracts and prove po1 and po2.")
    return generate_verified(prompt, SYSTEM_PROMPT_ARCHITECT, model, context=spec_code)


def extract_contracts(arch_code: str) -> list[str]:
    """Names of the component contracts defined by the architect."""
    return _CONTRACT_DEF.findall(arch_code)
