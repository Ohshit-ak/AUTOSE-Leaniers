import ContractForge
open ContractForge

-- 5.1/R5: The system shall be able to search for a specified product in less than 1 second.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  productCode : String
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.elapsedMicros < 1000000

example : Spec.pre { productCode := "A1" } ∧
          Spec.post { productCode := "A1" } { elapsedMicros := 999999 } := by
  unfold Spec; decide
