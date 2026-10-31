import ContractForge
open ContractForge

-- 3.4.3/S2: If the order is incorrect, the customer will be able to revise and update their order.
-- compiles: True · rejects_bad_example: None · checked: True

structure Order where
  items : List String
  quantity : Nat
  deriving DecidableEq, Repr

structure Input where
  order : Order
  deriving DecidableEq, Repr

structure Output where
  revised : Bool
  order : Order
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.order.quantity > 0
  post := fun i o => o.revised = true ↔
    (o.order.items = i.order.items ∧ o.order.quantity = i.order.quantity) ∨
    (o.order.items ≠ i.order.items ∨ o.order.quantity ≠ i.order.quantity)

example : Spec.pre { order := { items := ["item1"], quantity := 5 } } ∧
          Spec.post { order := { items := ["item1"], quantity := 5 } }
                    { revised := true, order := { items := ["item1"], quantity := 5 } } := by
  unfold Spec; decide
