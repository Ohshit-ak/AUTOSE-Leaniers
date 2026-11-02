import ContractForge
open ContractForge

-- 5.1/R4: The system shall be able to add product to shopping cart in less than 2ms.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros < 2000

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 1999 } := by
  unfold Spec; decide
