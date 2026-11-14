import ContractForge
open ContractForge

-- 3.4.3/S3: The customer will then receive a confirmation email with the specific order details.
-- compiles: True · rejects_bad_example: True · checked: True

structure Order where
  id      : Nat
  items   : List String
  total   : Nat
  deriving DecidableEq, Repr

structure Input where
  orderDetails : Order
  deriving DecidableEq, Repr

structure Output where
  sentEmail : Bool
  order     : Order
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.orderDetails.id ≠ 0
  post := fun i o => o.sentEmail = true ∧
                     o.order.id = i.orderDetails.id ∧
                     o.order.items = i.orderDetails.items ∧
                     o.order.total = i.orderDetails.total

example : Spec.pre { orderDetails := { id := 123, items := ["item1", "item2"], total := 150 } } ∧
          Spec.post { orderDetails := { id := 123, items := ["item1", "item2"], total := 150 } }
                     { sentEmail := true, order := { id := 123, items := ["item1", "item2"], total := 150 } } := by
  unfold Spec; decide
