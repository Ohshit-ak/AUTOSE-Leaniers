import ContractForge
open ContractForge

-- 3.4.3/S3: The customer will then receive a confirmation email with the specific order details.
-- compiles: True · rejects_bad_example: True · checked: True

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
  emailContent : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.email ≠ ""
  post := fun i o => o.sent = true ↔
    (o.emailContent = "Confirmation: " ++ i.order.item ++ " x" ++ i.order.quantity.toSubscriptString ++ " at $" ++ i.order.price.toSubscriptString)

example : Spec.pre { email := "customer@example.com", order := { item := "Laptop", quantity := 1, price := 999 } } ∧ Spec.post { email := "customer@example.com", order := { item := "Laptop", quantity := 1, price := 999 } } { sent := false, emailContent := "" } := by
  unfold Spec; decide
