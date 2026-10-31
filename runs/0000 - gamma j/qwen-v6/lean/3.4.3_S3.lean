import ContractForge
open ContractForge

-- 3.4.3/S3: The customer will then receive a confirmation email with the specific order details.
-- compiles: True · rejects_bad_example: None · checked: True

structure Order where
  item : String
  quantity : Nat
  price : Nat
  deriving DecidableEq, Repr

structure Input where
  email : String
  order : Order
  deriving DecidableEq, Repr

structure Output where
  sent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.email ≠ "" ∧ i.order.quantity > 0
  post := fun i o => o.sent = true ↔
    (i.email.toList.all Char.isAlpha = true ∧
     i.order.item ≠ "" ∧
     i.order.quantity > 0 ∧
     i.order.price > 0)

example : Spec.pre { email := "customer@example.com", order := { item := "Laptop", quantity := 1, price := 1000 } } ∧ Spec.post { email := "customer@example.com", order := { item := "Laptop", quantity := 1, price := 1000 } } { sent := false } := by
  unfold Spec; decide
