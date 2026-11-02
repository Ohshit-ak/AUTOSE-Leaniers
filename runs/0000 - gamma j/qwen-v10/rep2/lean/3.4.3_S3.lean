import ContractForge
open ContractForge

-- 3.4.3/S3: The customer will then receive a confirmation email with the specific order details.
-- compiles: True · rejects_bad_example: True · checked: True

structure Order where
  id       : Nat
  items    : List String
  total    : Nat
  customer : String
  deriving DecidableEq, Repr

structure Input where
  order : Order
  deriving DecidableEq, Repr

structure Output where
  sent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.order.id ≠ 0
  post := fun i o => o.sent = true ↔
    (∃ id ∈ i.order.items, true) ∧
    i.order.total = (i.order.items.map (fun item => 1)).sum

example : Spec.pre { order := { id := 1, items := ["item1", "item2"], total := 10, customer := "john" } } ∧ Spec.post { order := { id := 1, items := ["item1", "item2"], total := 10, customer := "john" } } { sent := false } := by
  unfold Spec; decide
