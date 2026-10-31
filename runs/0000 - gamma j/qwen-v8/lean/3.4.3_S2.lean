import ContractForge
open ContractForge

-- 3.4.3/S2: If the order is incorrect, the customer will be able to revise and update their order.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  orderItems : List Nat
  deriving DecidableEq, Repr

structure Output where
  orderItems : List Nat
  revised    : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.orderItems.length > 0
  post := fun i o => o.revised = true ↔
    ∃ j ∈ i.orderItems, j < 100 ∧
    o.orderItems = i.orderItems.filter (fun x => x ≥ 100)

example : Spec.pre { orderItems := [100, 200, 300] } ∧ Spec.post { orderItems := [100, 200, 300] } { orderItems := [200, 300], revised := false } := by
  unfold Spec; decide
