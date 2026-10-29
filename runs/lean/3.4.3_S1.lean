-- 3.4.3/S1: Customers will be able to confirm the order after checkout.
-- checked: None

structure Order where
  items : List String
  total : Nat

structure Confirmation where
  order : Order
  confirmed : Bool

def Spec : Contract Order Confirmation where
  pre order := true
  post order confirmation := confirmation.confirmed

example : Spec order confirmation := by
  let order := Order.mk [] 0
  let confirmation := Confirmation.mk order true
  exact confirmation
