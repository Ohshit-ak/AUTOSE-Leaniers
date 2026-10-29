-- UC-customer-add-item-to-cart: Add Item To Cart: Customer adds item(s) in the cart
-- checked: None

structure Contract (α β : Type) where
  pre  : α → Prop
  post : α → β → Prop

structure Input where
  customerLogged : Bool
  cartItems      : List String

structure Output where
  customerConfirmed : Bool
  storedCookie      : Bool
  finalCartItems    : List String

def Spec : Contract Input Output where
  pre i := i.customerLogged
  post i o := 
    i.customerLogged ∧ 
    o.customerConfirmed ∧ 
    o.storedCookie ∧ 
    List.Pairwise (· ≤ ·) i.cartItems o.finalCartItems

example : ∃ i : Input, Spec.pre i :=
begin
  use { customerLogged := true, cartItems := ["item1", "item2"] },
  simp,
end
