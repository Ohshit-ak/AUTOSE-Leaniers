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
  isCorrect : Bool
  deriving DecidableEq, Repr

structure Output where
  revisedOrder : Order
  accepted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.currentOrder.quantity ≠ 0
  post := fun i o => (o.accepted = true ↔
    (i.isCorrect ∧
     o.revisedOrder.quantity = i.revisedQuantity ∧
     o.revisedOrder.items = i.revisedItems)) ∧
                    (o.accepted = false ↔
                     ¬i.isCorrect ∧
                     o.revisedOrder = i.currentOrder)

example : Spec.pre { currentOrder := { items := ["apple"], quantity := 5 },
                     revisedItems := ["banana"], revisedQuantity := 10,
                     isCorrect := true } ∧
          Spec.post { currentOrder := { items := ["apple"], quantity := 5 },
                      revisedItems := ["banana"], revisedQuantity := 10,
                      isCorrect := true }
                    { revisedOrder := { items := ["banana"], quantity := 10 },
                      accepted := true } := by
  unfold Spec; decide

example : Spec.pre { currentOrder := { items := ["apple"], quantity := 5 },
                     revisedItems := ["banana"], revisedQuantity := 10,
                     isCorrect := false } ∧
          Spec.post { currentOrder := { items := ["apple"], quantity := 5 },
                      revisedItems := ["banana"], revisedQuantity := 10,
                      isCorrect := false }
                    { revisedOrder := { items := ["apple"], quantity := 5 },
                      accepted := false } := by
  unfold Spec; decide
