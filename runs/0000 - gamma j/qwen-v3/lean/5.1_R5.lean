-- 5.1/R5: The system shall be able to search for a specified product in less than 1 second.
-- checked: True

structure Input where
  productCode : String
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  found         : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.found = true → o.elapsedMicros < 1000000

example : Spec.pre { productCode := "A123" } ∧
          Spec.post { productCode := "A123" }
                     { found := true, elapsedMicros := 999999 } := by
  unfold Spec; decide
