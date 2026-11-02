import ContractForge
open ContractForge

-- 3.4.3/S2: If the order is incorrect, the customer will be able to revise and update their order.
-- compiles: True · rejects_bad_example: None · checked: False

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
  post := fun i o => o.revised = true ↔
    ∃ j ∈ i.order.items, o.order = { items := i.order.items, quantity := i.order.quantity - 1 }

example : Spec.pre { order := { items := ["item1", "item2"], quantity := 2 } } ∧
          Spec.post { order := { items := ["item1", "item2"], quantity := 2 } }
                    { order := { items := ["item1", "item2"], quantity := 1 }, revised := true } := by
  unfold Spec; decide
