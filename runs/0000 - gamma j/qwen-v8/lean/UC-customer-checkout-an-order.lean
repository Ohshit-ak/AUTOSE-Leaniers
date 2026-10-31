import ContractForge
open ContractForge

-- UC-customer-checkout-an-order: Checkout An Order: Customer places and confirms an order for the checkout process.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  signedIn : Bool
  itemsInCart : List String
  cookie : Option String
  terminating : Bool
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  cookie : Option String
  emailSent : Bool
  orderConfirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true ∧ i.itemsInCart.Nodup ∧ i.cookie = none ∧ ¬i.terminating
  post := fun i o => (o.orderConfirmed = true ↔ ¬i.terminating) ∧
                     o.signedIn = i.signedIn ∧
                     o.cookie = some "checkout" ∧
                     o.emailSent = true

example : Spec.pre { signedIn := true, itemsInCart := ["item1"], cookie := none, terminating := false } ∧ Spec.post { signedIn := true, itemsInCart := ["item1"], cookie := none, terminating := false } { signedIn := true, cookie := some "checkout", emailSent := true, orderConfirmed := true } := by
  unfold Spec; decide
