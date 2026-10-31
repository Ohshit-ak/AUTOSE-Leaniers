-- UC-customer-add-item-to-cart: Add Item To Cart: Customer adds item(s) in the cart
-- checked: True

structure Input where
  signedIn : Bool
  pending  : Nat
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  pending  : Nat
  done     : Bool
  itemsInCart : List Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => o.done = true ∧
                     o.signedIn = i.signedIn ∧
                     o.pending = i.pending - 1 ∧
                     o.itemsInCart.Nodup ∧
                     o.itemsInCart.length > 0

example : Spec.pre { signedIn := true, pending := 2 } ∧ Spec.post { signedIn := true, pending := 2 } { signedIn := true, pending := 1, done := true, itemsInCart := [5] } := by
  unfold Spec; decide
