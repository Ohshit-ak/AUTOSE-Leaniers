import ContractForge
open ContractForge

-- 3.2.4.9/S9: Requirement If attestations are described sufficiently in multiple lingual versions they SHOULD be included first to stages 3 and 4.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  attestations : List String
  deriving DecidableEq, Repr

structure Output where
  included : Bool
  stage    : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.attestations.length ≥ 2
  post := fun i o => o.included = true ↔
    (o.stage = 3 ∨ o.stage = 4) ∧
    (o.stage = 3 ↔ i.attestations.length ≥ 2) ∧
    (o.stage = 4 ↔ i.attestations.length ≥ 2) ∧
    (o.included = true ↔ i.attestations.length ≥ 2)

example : Spec.pre { attestations := ["att1", "att2"] } ∧ Spec.post { attestations := ["att1", "att2"] } { included := false, stage := 3 } := by
  unfold Spec; decide
