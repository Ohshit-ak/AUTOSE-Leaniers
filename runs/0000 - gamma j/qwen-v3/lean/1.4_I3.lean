-- 1.4/I3: Confirm Orders
-- checked: True

structure Input where
  orderID : Nat
  customerName : String
  item : String
  quantity : Nat
  deriving DecidableEq, Repr

structure Output where
  orderID : Nat
  customerName : String
  item : String
  quantity : Nat
  accepted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.quantity > 0
  post := fun i o => o.orderID = i.orderID ∧
                     o.customerName = i.customerName ∧
                     o.item = i.item ∧
                     o.quantity = i.quantity ∧
                     o.accepted = true

example : Spec.pre { orderID := 1, customerName := "Alice", item := "Book", quantity := 5 } ∧
          Spec.post { orderID := 1, customerName := "Alice", item := "Book", quantity := 5 }
                     { orderID := 1, customerName := "Alice", item := "Book", quantity := 5, accepted := true } := by
  unfold Spec; decide
