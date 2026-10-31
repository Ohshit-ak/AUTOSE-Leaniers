import ContractForge
open ContractForge

-- UC-customer-add-item-to-cart: Add Item To Cart: Customer adds item(s) in the cart
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  signedIn : Bool
  cart     : List String
  cookie   : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  cart     : List String
  cookie   : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => (o.signedIn = i.signedIn ∧ o.cart = i.cart) ∧
                     (o.cookie ≠ "" ↔ i.signedIn = true)

example : Spec.pre { signedIn := true, cart := ["item1", "item2"], cookie := "cart_details" } ∧
          Spec.post { signedIn := true, cart := ["item1", "item2"], cookie := "cart_details" }
                    { signedIn := true, cart := ["item1", "item2"], cookie := "cart_details" } := by
  unfold Spec; decide
