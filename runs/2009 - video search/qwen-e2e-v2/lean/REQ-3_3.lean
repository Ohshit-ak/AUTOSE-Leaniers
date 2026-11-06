import ContractForge
open ContractForge

-- REQ-3#3: Loading the program will take less than 10 seconds.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros < 10000000

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 9000000 } := by
  unfold Spec; decide
