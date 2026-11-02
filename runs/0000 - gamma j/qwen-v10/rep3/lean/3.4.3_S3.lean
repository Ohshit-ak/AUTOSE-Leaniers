import ContractForge
open ContractForge

-- 3.4.3/S3: The customer will then receive a confirmation email with the specific order details.
-- compiles: True · rejects_bad_example: True · checked: True

structure Order where
  id       : Nat
  customer : String
  items    : List String
  total    : Nat
  deriving DecidableEq, Repr

structure Input where
  order : Order
  email : String
  deriving DecidableEq, Repr

structure Output where
  sent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.email ≠ ""
  post := fun i o => o.sent = true ↔
    (i.order.items.length > 0 ∧
     i.order.total > 0 ∧
     i.email.toList.all Char.isAlphanum = true)

example : Spec.pre { order := { id := 1, customer := "Alice", items := ["Item1", "Item2"], total := 100 }, email := "alice@example.com" } ∧ Spec.post { order := { id := 1, customer := "Alice", items := ["Item1", "Item2"], total := 100 }, email := "alice@example.com" } { sent := false } := by
  unfold Spec; decide
