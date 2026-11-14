import ContractForge
open ContractForge

-- Design Constraints/I1#9: The system admin only can able to create User Groups
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  admin : Bool
  deriving DecidableEq, Repr

structure Output where
  created : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.admin
  post := fun i o => o.created = true

example : Spec.pre { admin := true } ∧ Spec.post { admin := true } { created := true } := by
  unfold Spec; decide
