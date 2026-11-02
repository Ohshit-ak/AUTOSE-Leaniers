import ContractForge
open ContractForge

-- 3.4.3/S2: If the order is incorrect, the customer will be able to revise and update their order.
-- compiles: True · rejects_bad_example: True · checked: True

structure Order where
  items : List String
  quantity : Nat
  deriving DecidableEq, Repr

structure Input where
  currentOrder : Order
  revisedItems : List String
  revisedQuantity : Nat
  isOrderCorrect : Bool
  deriving DecidableEq, Repr

structure Output where
  updatedOrder : Order
  isOrderPlaced : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.currentOrder.quantity > 0
  post := fun i o => (o.isOrderPlaced ↔ i.isOrderCorrect) ∧
                     (o.isOrderPlaced ↔
                       (o.updatedOrder.items = i.revisedItems ∧
                        o.updatedOrder.quantity = i.revisedQuantity ∧
                        o.updatedOrder.quantity > 0)) ∧
                     (¬o.isOrderPlaced ↔
                       (o.updatedOrder.items = i.currentOrder.items ∧
                        o.updatedOrder.quantity = i.currentOrder.quantity))

example : Spec.pre { currentOrder := { items := ["Item1"], quantity := 5 },
                     revisedItems := ["Item2"], revisedQuantity := 3,
                     isOrderCorrect := true } ∧
          Spec.post { currentOrder := { items := ["Item1"], quantity := 5 },
                      revisedItems := ["Item2"], revisedQuantity := 3,
                      isOrderCorrect := true }
                    { updatedOrder := { items := ["Item2"], quantity := 3 },
                      isOrderPlaced := true } := by
  unfold Spec; decide

example : Spec.pre { currentOrder := { items := ["Item1"], quantity := 5 },
                     revisedItems := ["IncorrectItem"], revisedQuantity := 10,
                     isOrderCorrect := false } ∧
          Spec.post { currentOrder := { items := ["Item1"], quantity := 5 },
                      revisedItems := ["IncorrectItem"], revisedQuantity := 10,
                      isOrderCorrect := false }
                    { updatedOrder := { items := ["Item1"], quantity := 5 },
                      isOrderPlaced := false } := by
  unfold Spec; decide
