-- 1.4/I3: Confirm Orders
-- checked: False

structure Input where
  orderID : Nat
  quantity : Nat
  itemCode : String
  deriving DecidableEq, Repr

structure Output where
  orderID : Nat
  accepted : Bool
  message : String
  quantity : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.quantity > 0 ∧ i.itemCode.length = 4
  post := fun i o => o.accepted = true ↔ i.quantity ≤ 100 ∧
                      (o.accepted = false → o.message = "Order rejected: quantity exceeds limit" ∧ o.quantity > 100)

example : Spec.pre { orderID := 1, quantity := 50, itemCode := "ABCD" } ∧
          Spec.post { orderID := 1, quantity := 50, itemCode := "ABCD" }
                     { orderID := 1, accepted := true, message := "", quantity := 50 } := by
  unfold Spec; decide

example : Spec.pre { orderID := 2, quantity := 200, itemCode := "ABCD" } ∧
          Spec.post { orderID := 2, quantity := 200, itemCode := "ABCD" }
                     { orderID := 2, accepted := false, message := "Order rejected: quantity exceeds limit", quantity := 200 } := by
  unfold Spec; decide
