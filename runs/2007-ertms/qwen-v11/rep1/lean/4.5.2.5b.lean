import ContractForge
open ContractForge

-- 4.5.2.5b: The supervised speed shall not be shown on the DMI.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  speed : Nat
  deriving DecidableEq, Repr

structure Output where
  speedVisible : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.speed = 0
  post := fun i o => o.speedVisible = false

example : Spec.pre { speed := 0 } ∧ Spec.post { speed := 0 } { speedVisible := false } := by
  unfold Spec; decide
