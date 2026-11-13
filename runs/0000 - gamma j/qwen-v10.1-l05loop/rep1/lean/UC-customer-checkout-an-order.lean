import ContractForge
open ContractForge

-- UC-customer-checkout-an-order: Checkout An Order: Customer places and confirms an order for the checkout process.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  signedIn : Bool
  cart     : List String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  cart     : List String
  order    : String
  emailSent : Bool
  cookieCheckout : Bool
  cookieCompleted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true ∧ i.cart.Nodup
  post := fun i o => o.signedIn = i.signedIn ∧
                     o.cart = i.cart ∧
                     o.order = "Order Confirmed" ∧
                     o.emailSent = true ∧
                     o.cookieCheckout = true ∧
                     o.cookieCompleted = true

example : Spec.pre { signedIn := true, cart := ["item1", "item2"] } ∧
          Spec.post { signedIn := true, cart := ["item1", "item2"],
                      order := "Order Confirmed", emailSent := true,
                      cookieCheckout := true, cookieCompleted := true } := by
  unfold Spec; decide
