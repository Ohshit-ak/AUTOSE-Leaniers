import ContractForge
open ContractForge

-- 1.4/I3: Confirm Orders
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  orderAmount : Nat
  stockLevel  : Nat
  deriving DecidableEq, Repr

structure Output where
  orderPlaced : Bool
  newStockLevel : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.orderAmount ∧ i.orderAmount ≤ i.stockLevel
  post := fun i o => (o.orderPlaced = true ↔ i.orderAmount ≤ i.stockLevel) ∧
                     (o.orderPlaced = true → o.newStockLevel = i.stockLevel - i.orderAmount) ∧
                     (o.orderPlaced = false → o.newStockLevel = i.stockLevel)

example : Spec.pre { orderAmount := 5, stockLevel := 10 } ∧
          Spec.post { orderAmount := 5, stockLevel := 10 }
                    { orderPlaced := true, newStockLevel := 5 } := by
  unfold Spec; decide
