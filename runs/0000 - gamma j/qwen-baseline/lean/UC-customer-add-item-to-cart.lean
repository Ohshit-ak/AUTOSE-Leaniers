-- UC-customer-add-item-to-cart: Add Item To Cart: Customer adds item(s) in the cart
-- checked: False

structure Input where
  customerLogged : Bool
  itemsToAdd     : List String
  cartCookie     : Option String

structure Output where
  cartUpdated    : Bool
  itemsInCart    : List String

def Spec : Contract Input Output where
  pre  := fun i => i.customerLogged
  post := fun i o => o.cartUpdated ∧ i.itemsToAdd =· o.itemsInCart

example : Spec.pre ⟨true, [], none⟩ ∧ Spec.post ⟨true, [], []⟩ ⟨true, [], []⟩ := by
  simp [Spec]
