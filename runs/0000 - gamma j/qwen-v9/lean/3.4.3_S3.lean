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
  customerEmail : String
  order         : Order
  includeDetails : Bool
  deriving DecidableEq, Repr

structure Output where
  sentEmail : Bool
  message   : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.customerEmail ≠ "" ∧ i.order.items.Nodup ∧ i.order.total > 0
  post := fun i o => (o.sentEmail = true ↔
    i.includeDetails = true ∧
    i.order.items.Nodup ∧
    i.order.total > 0) ∧
    (o.sentEmail = false →
    (i.includeDetails = false ∧
    o.message = "Email sent without order details."))

example : Spec.pre { customerEmail := "customer@example.com", order := { id := 1, items := ["item1"], total := 100 }, includeDetails := true } ∧ Spec.post { customerEmail := "customer@example.com", order := { id := 1, items := ["item1"], total := 100 }, includeDetails := true } { sentEmail := true, message := "Order confirmation sent." } := by
  unfold Spec; decide
