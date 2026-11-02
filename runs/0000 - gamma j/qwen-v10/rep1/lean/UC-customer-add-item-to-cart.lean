import ContractForge
open ContractForge

-- UC-customer-add-item-to-cart: Add Item To Cart: Customer adds item(s) in the cart
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  signedIn : Bool
  items    : List String
  cookie   : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  items    : List String
  cookie   : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => (o.signedIn = i.signedIn) ∧
                     (o.items = i.items) ∧
                     (o.cookie ≠ "" →
                      (∃ cartItems ∈ o.items, cartItems ∈ i.items) ∧
                      (o.cookie = "cartDetails")) ∧
                     (o.cookie = "" → o.items = [])

example : Spec.pre { signedIn := true, items := ["item1", "item2"], cookie := "" } ∧
          Spec.post { signedIn := true, items := ["item1", "item2"], cookie := "cartDetails" }
                    { signedIn := true, items := ["item1", "item2"], cookie := "cartDetails" } := by
  unfold Spec; decide
