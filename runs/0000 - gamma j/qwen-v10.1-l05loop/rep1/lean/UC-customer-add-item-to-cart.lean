import ContractForge
open ContractForge

-- UC-customer-add-item-to-cart: Add Item To Cart: Customer adds item(s) in the cart
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  signedIn : Bool
  items    : List String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  items    : List String
  cookie   : Option String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => o.signedIn = i.signedIn ∧
                     o.items = i.items ∧
                     o.cookie.isSome ↔
                     (i.items.length > 0 ∧
                      ∃ cookie, cookie.Nodup ∧
                      ∀ item ∈ i.items, cookie.contains item)

example : Spec.pre { signedIn := true, items := ["item1", "item2"] } ∧
          Spec.post { signedIn := true, items := ["item1", "item2"], cookie := some "cart123" } := by
  unfold Spec; decide
