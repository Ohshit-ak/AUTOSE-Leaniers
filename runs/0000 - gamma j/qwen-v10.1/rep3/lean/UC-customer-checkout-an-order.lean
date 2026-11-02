import ContractForge
open ContractForge

-- UC-customer-checkout-an-order: Checkout An Order: Customer places and confirms an order for the checkout process.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  signedIn : Bool
  cart     : List String
  deriving DecidableEq, Repr

structure Output where
  confirmed : Bool
  orderID   : Nat
  emailSent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true ∧ i.cart.Nodup
  post := fun i o => o.confirmed = true ∧
                     (o.emailSent ↔ true) ∧
                     (o.orderID = 0 → false) ∧
                     (o.orderID ≠ 0 ↔ true)

example : Spec.pre { signedIn := true, cart := ["item1", "item2"] } ∧
          Spec.post { signedIn := true, cart := ["item1", "item2"] }
                    { confirmed := true, orderID := 1234, emailSent := true } := by
  unfold Spec; decide
