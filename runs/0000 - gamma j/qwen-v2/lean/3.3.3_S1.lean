-- 3.3.3/S1: Customers will also be able to add products into the shopping cart.
-- checked: True

structure Input where
  productID : Nat
  inCart    : Bool
  deriving DecidableEq, Repr

structure Output where
  inCart    : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.inCart = false
  post := fun i o => o.inCart = true

example : Spec.pre { productID := 1, inCart := false } ∧
          Spec.post { productID := 1, inCart := false } { inCart := true } := by
  unfold Spec; decide
