-- 5.1/R4: The system shall be able to add product to shopping cart in less than 2ms.
-- checked: True

structure Input where
  productID : Nat
  deriving DecidableEq, Repr

structure Output where
  accepted : Bool
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.accepted = true ∧ o.elapsedMicros < 2000

example : Spec.pre { productID := 123 } ∧
          Spec.post { productID := 123 } { accepted := true, elapsedMicros := 1999 } := by
  unfold Spec; decide
