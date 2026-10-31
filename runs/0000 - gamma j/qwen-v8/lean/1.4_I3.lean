import ContractForge
open ContractForge

-- 1.4/I3: Confirm Orders
-- compiles: False · rejects_bad_example: None · checked: False

structure Order where
  item : String
  quantity : Nat
  deriving DecidableEq, Repr

structure Input where
  stockLevels : List Order
  order : Order
  deriving DecidableEq, Repr

structure Output where
  accepted : Bool
  quantity : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.order.quantity ≤ i.stockLevels.filter (·.item = i.order.item).sum.quantity
  post := fun i o => o.accepted = true ↔ i.order.quantity ≤ i.stockLevels.filter (·.item = i.order.item).sum.quantity ∧
                      o.quantity = min i.order.quantity (i.stockLevels.filter (·.item = i.order.item).sum.quantity)

example : Spec.pre { stockLevels := [{ item := "A1", quantity := 10 },
                                      { item := "A2", quantity := 20 }],
                     order := { item := "A1", quantity := 5 } } ∧
          Spec.post { stockLevels := [{ item := "A1", quantity := 10 },
                                       { item := "A2", quantity := 20 }],
                      order := { item := "A1", quantity := 5 } }
                    { accepted := true, quantity := 5 } := by
  unfold Spec; decide
