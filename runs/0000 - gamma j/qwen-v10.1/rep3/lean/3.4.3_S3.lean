import ContractForge
open ContractForge

-- 3.4.3/S3: The customer will then receive a confirmation email with the specific order details.
-- compiles: True · rejects_bad_example: None · checked: False

structure Order where
  id       : Nat
  customer : String
  items    : List String
  total    : Nat
  deriving DecidableEq, Repr

structure Input where
  customerEmail : String
  order         : Order
  deriving DecidableEq, Repr

structure Output where
  sentEmail : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.customerEmail ≠ ""
  post := fun i o => (o.sentEmail = true ↔
    i.order.items.Nodup ∧
    i.order.total > 0 ∧
    i.customerEmail.toList.all Char.isAlphanum = true)

example : Spec.pre { customerEmail := "john.doe@example.com", order := { id := 1, customer := "John Doe", items := ["Item1", "Item2"], total := 100 } } ∧ Spec.post { customerEmail := "john.doe@example.com", order := { id := 1, customer := "John Doe", items := ["Item1", "Item2"], total := 100 } } { sentEmail := false } := by
  unfold Spec; decide
