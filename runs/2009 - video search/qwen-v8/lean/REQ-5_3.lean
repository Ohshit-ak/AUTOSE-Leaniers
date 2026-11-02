import ContractForge
open ContractForge

-- REQ-5#3: Sorting results should take less than 0.1 seconds.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros < 100000

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 95000 } := by
  unfold Spec; decide
