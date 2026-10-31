-- UC-customer-checkout-an-order: Checkout An Order: Customer places and confirms an order for the checkout process.
-- checked: True

structure Input where
  signedIn : Bool
  shoppingCart : List Nat
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  shoppingCart : List Nat
  orderConfirmed : Bool
  emailSent : Bool
  cookieCheckout : Bool
  cookieCompleted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true ∧ i.shoppingCart.Nodup
  post := fun i o => o.orderConfirmed = true ∧
                     o.emailSent = true ∧
                     o.cookieCheckout = true ∧
                     o.cookieCompleted = true ∧
                     o.signedIn = i.signedIn ∧
                     o.shoppingCart = i.shoppingCart

example : Spec.pre { signedIn := true, shoppingCart := [1, 2, 3] } ∧
          Spec.post { signedIn := true, shoppingCart := [1, 2, 3] }
                    { orderConfirmed := true, emailSent := true, cookieCheckout := true, cookieCompleted := true, signedIn := true, shoppingCart := [1, 2, 3] } := by
  unfold Spec; decide
