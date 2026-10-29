-- UC-customer-checkout-an-order: Checkout An Order: Customer places and confirms an order for the checkout process.
-- checked: None

structure Contract (Input Output) where
  pre  : Input → Prop
  post : Input → Output → Prop

structure Input where
  logged_in : Bool
  shopping_cart : List String
  cookie : Option String

structure Output where
  order_confirmed : Bool
  order_details : List String
  email_confirmation_sent : Bool
  cookie_completed : Option String

def Spec : Contract Input Output :=
  { pre := λ i, i.logged_in ∧ i.shopping_cart ≠ [] ∧ i.cookie = none
    , post := λ i o, o.order_confirmed ∧ o.order_details ≠ [] ∧ o.email_confirmation_sent ∧ o.cookie_completed = some "checkout_completed" }

example : ∃ i, Spec.pre i ∧ Spec.post i (Spec.post i i) := 
begin
  existsi { logged_in := true, shopping_cart := ["item1", "item2"], cookie := none },
  split,
  { simp },
  { unfold Spec.post,
    simp }
end
