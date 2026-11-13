import ContractForge
open ContractForge

-- 3.2.4.9/S9: Requirement If attestations are described sufficiently in multiple lingual versions they SHOULD be included first to stages 3 and 4.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  attestations : List String
  language     : String
  deriving DecidableEq, Repr

structure Output where
  included : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.attestations.length > 0
  post := fun i o => o.included = true ↔
    (i.language = "en" ∧ i.attestations.length > 1) ∨
    (i.language ≠ "en" ∧ i.attestations.length > 0)

example : Spec.pre { attestations := ["att1", "att2"], language := "en" } ∧
          Spec.post { attestations := ["att1", "att2"], language := "en" }
                    { included := true } := by
  unfold Spec; decide
