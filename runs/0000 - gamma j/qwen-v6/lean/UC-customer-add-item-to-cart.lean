import ContractForge
open ContractForge

-- UC-customer-add-item-to-cart: Add Item To Cart: Customer adds item(s) in the cart
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  signedIn : Bool
  cart     : List String
  done     : Bool
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  cart     : List String
  done     : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => (o.done = true ↔
    i.cart = o.cart) ∧
                     (o.signedIn = i.signedIn) ∧
                     (o.done = false →
                      ∃ s ∈ i.cart, s ≠ "")

example : Spec.pre { signedIn := true, cart := ["item1", "item2"], done := false } ∧
          Spec.post { signedIn := true, cart := ["item1", "item2"], done := true } := by
  unfold Spec; decide
