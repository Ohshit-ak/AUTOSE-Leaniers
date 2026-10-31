-- 3.3.3/S1: Customers will also be able to add products into the shopping cart.
-- checked: True

structure Input where
  productID : String
  quantity  : Nat
  cartItems : List (String × Nat)
  deriving DecidableEq, Repr

structure Output where
  added     : Bool
  cartItems : List (String × Nat)
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.productID.length ≤ 100
  post := fun i o => o.added = true ∧
                     (o.cartItems = i.cartItems ++ [(i.productID, i.quantity)] ∨
                      o.cartItems = i.cartItems.filter (fun p => p.1 ≠ i.productID) ++ [(i.productID, i.quantity)])

example : Spec.pre { productID := "A1", quantity := 5, cartItems := [] } ∧
          Spec.post { productID := "A1", quantity := 5, cartItems := [] }
                     { added := true, cartItems := [("A1", 5)] } := by
  unfold Spec; decide
