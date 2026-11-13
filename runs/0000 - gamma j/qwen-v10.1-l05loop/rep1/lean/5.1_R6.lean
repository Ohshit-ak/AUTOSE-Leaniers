import ContractForge
open ContractForge

-- 5.1/R6: The system shall be able to email customer and vendor in less than 1 second.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros < 1000000

example : Spec.pre { } ∧ Spec.post { } { elapsedMicros := 950000 } := by
  unfold Spec; decide
