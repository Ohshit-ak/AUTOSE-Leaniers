-- 1.4/I3: Confirm Orders
-- checked: None

structure Order where
  customerName : String
  orderItems   : List String
  quantity     : Nat

structure Confirmation where
  customerName : String
  orderItems   : List String
  quantity     : Nat
  confirmation : Bool

def Spec : Contract Order Confirmation where
  pre o := true
  post o c := o.customerName = c.customerName ∧ o.orderItems = c.orderItems ∧ o.quantity = c.quantity ∧ c.confirmation

example : Spec
:= by
  let o := Order.mk "John Doe" ["Item A", "Item B"] 5
  let c := Confirmation.mk "John Doe" ["Item A", "Item B"] 5 true
  show Spec from
    by
      simp [Spec]
      exact true
