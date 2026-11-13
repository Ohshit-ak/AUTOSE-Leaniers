import ContractForge
open ContractForge

-- 3.10.1/S6: In fact an entry can be added with no fields at all.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  description : Option String
  deriving DecidableEq, Repr

structure Output where
  accepted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.accepted = true ↔ i.description = none

example : Spec.pre { description := none } ∧
          Spec.post { description := none } { accepted := true } := by
  unfold Spec; decide
