-- UC-customer-add-item-to-cart: Add Item To Cart: Customer adds item(s) in the cart
-- checked: True

structure Input where
  signedIn : Bool
  items    : List Nat
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  items    : List Nat
  done     : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => o.done = true ∧
                     o.signedIn = i.signedIn ∧
                     o.items = i.items

example : Spec.pre { signedIn := true, items := [1, 2, 3] } ∧
          Spec.post { signedIn := true, items := [1, 2, 3] }
                    { signedIn := true, items := [1, 2, 3], done := true } := by
  unfold Spec; decide
