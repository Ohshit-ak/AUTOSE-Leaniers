import ContractForge
open ContractForge

-- UC-customer-add-item-to-cart: Add Item To Cart: Customer adds item(s) in the cart
-- compiles: True · rejects_bad_example: None · checked: True

structure Cart where
  items : List String
  deriving DecidableEq, Repr

structure Input where
  signedIn : Bool
  itemsToAdd : List String
  cookieStored : Bool
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  itemsInCart : List String
  cookieStored : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => o.signedIn = i.signedIn ∧
                     o.itemsInCart = i.itemsToAdd ++ o.itemsInCart ∧
                     o.cookieStored = true

example : Spec.pre { signedIn := true, itemsToAdd := [], cookieStored := true } ∧ Spec.post { signedIn := true, itemsToAdd := [], cookieStored := true } { signedIn := true, itemsInCart := ["item1", "item2"], cookieStored := true } := by
  unfold Spec; decide
