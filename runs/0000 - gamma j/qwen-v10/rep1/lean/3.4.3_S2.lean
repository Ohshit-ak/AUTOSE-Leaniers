import ContractForge
open ContractForge

-- 3.4.3/S2: If the order is incorrect, the customer will be able to revise and update their order.
-- compiles: True · rejects_bad_example: True · checked: True

structure Order where
  items : List String
  quantity : Nat
  deriving DecidableEq, Repr

structure Input where
  order : Order
  deriving DecidableEq, Repr

structure Output where
  order : Order
  revised : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.order.quantity > 0
  post := fun i o => (o.revised = true ↔
    ∃ items ∈ i.order.items, items.length > 1) ∧
    o.order.items = i.order.items ∧
    o.order.quantity = i.order.quantity

example : Spec.pre { order := { items := ["apple", "banana"], quantity := 2 } } ∧
          Spec.post { order := { items := ["apple", "banana"], quantity := 2 } }
                    { revised := true, order := { items := ["apple", "banana"], quantity := 2 } } := by
  unfold Spec; decide
