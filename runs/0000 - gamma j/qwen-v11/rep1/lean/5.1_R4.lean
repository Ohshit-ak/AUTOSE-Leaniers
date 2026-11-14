import ContractForge
open ContractForge

-- 5.1/R4: The system shall be able to add product to shopping cart in less than 2ms.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.elapsedMicros < 2000
  post := fun i o => o.elapsedMicros = i.elapsedMicros + 0 ∧
                     o.elapsedMicros < 2000

example : Spec.pre { elapsedMicros := 1999 } ∧ Spec.post { elapsedMicros := 1999 } { elapsedMicros := 1999 } := by
  unfold Spec; decide
