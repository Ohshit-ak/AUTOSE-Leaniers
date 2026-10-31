-- UC-customer-checkout-an-order: Checkout An Order: Customer places and confirms an order for the checkout process.
-- checked: True

structure Input where
  signedIn : Bool
  pending  : Nat
  itemsInCart : Bool
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  pending  : Nat
  done     : Bool
  emailSent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true ∧ i.itemsInCart = true
  post := fun i o => o.done = true ∧ o.emailSent = true ∧ o.pending = i.pending - 1 ∧ o.signedIn = i.signedIn

example : Spec.pre { signedIn := true, pending := 2, itemsInCart := true } ∧
          Spec.post { signedIn := true, pending := 2, itemsInCart := true }
                    { signedIn := true, pending := 1, done := true, emailSent := true } := by
  unfold Spec; decide
