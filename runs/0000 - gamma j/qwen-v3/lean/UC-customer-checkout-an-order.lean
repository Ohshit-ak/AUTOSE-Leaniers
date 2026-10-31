-- UC-customer-checkout-an-order: Checkout An Order: Customer places and confirms an order for the checkout process.
-- checked: True

structure Input where
  signedIn : Bool
  shoppingCart : List String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  shoppingCart : List String
  orderConfirmed : Bool
  emailSent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true ∧ i.shoppingCart.Nodup
  post := fun i o => o.signedIn = i.signedIn ∧
                     o.shoppingCart = i.shoppingCart ∧
                     o.orderConfirmed = true ∧
                     o.emailSent = true

example : Spec.pre { signedIn := true, shoppingCart := ["Item1", "Item2"] } ∧
          Spec.post { signedIn := true, shoppingCart := ["Item1", "Item2"] }
                    { signedIn := true, shoppingCart := ["Item1", "Item2"], orderConfirmed := true, emailSent := true } := by
  unfold Spec; decide
