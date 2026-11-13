import ContractForge
open ContractForge

-- 13.5.5/S1: Railway Emergency call confirmation messages shall be of eMLPP priority 4 - "Railway information and all other calls" (see section 10.2).
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  priority : Nat
  deriving DecidableEq, Repr

structure Output where
  confirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.priority = 4
  post := fun i o => o.confirmed = true

example : Spec.pre { priority := 4 } ∧ Spec.post { priority := 4 } { confirmed := true } := by
  unfold Spec; decide
