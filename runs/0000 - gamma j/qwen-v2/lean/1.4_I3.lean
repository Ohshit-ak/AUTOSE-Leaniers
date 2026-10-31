-- 1.4/I3: Confirm Orders
-- checked: True

structure Input where
  orderID : Nat
  quantity : Nat
  itemCode : String
  deriving DecidableEq, Repr

structure Output where
  orderID : Nat
  accepted : Bool
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.quantity ≥ 0 ∧ i.itemCode.length ≤ 10
  post := fun i o => o.accepted = true ↔ i.quantity > 0 ∧
                      o.message = "Order confirmed" ∧
                      o.orderID = i.orderID

example : Spec.pre { orderID := 123, quantity := 5, itemCode := "A1" } ∧
          Spec.post { orderID := 123, quantity := 5, itemCode := "A1" }
                     { accepted := true, message := "Order confirmed", orderID := 123 } := by
  unfold Spec; decide
