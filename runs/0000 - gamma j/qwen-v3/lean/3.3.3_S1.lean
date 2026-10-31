-- 3.3.3/S1: Customers will also be able to add products into the shopping cart.
-- checked: True

structure Input where
  productID : Nat
  productPrice : Nat
  deriving DecidableEq, Repr

structure Output where
  added : Bool
  cartTotal : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.added = true ∧
                     o.cartTotal = i.productPrice

example : Spec.pre { productID := 1, productPrice := 50 } ∧
          Spec.post { productID := 1, productPrice := 50 }
                    { added := true, cartTotal := 50 } := by
  unfold Spec; decide
