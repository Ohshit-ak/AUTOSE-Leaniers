-- 5.1/R5: The system shall be able to search for a specified product in less than 1 second.
-- checked: True

structure Input where
  productCode : String
  deriving DecidableEq, Repr

structure Output where
  valid      : Bool
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ∧ o.elapsedMicros < 1000000

example : Spec.pre { productCode := "A1" } ∧
          Spec.post { productCode := "A1" }
                     { valid := true, elapsedMicros := 999999 } := by
  unfold Spec; decide
