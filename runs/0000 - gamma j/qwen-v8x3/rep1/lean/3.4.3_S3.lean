import ContractForge
open ContractForge

-- 3.4.3/S3: The customer will then receive a confirmation email with the specific order details.
-- compiles: True · rejects_bad_example: True · checked: True

structure Order where
  id     : Nat
  amount : Nat
  details: String
  deriving DecidableEq, Repr

structure Input where
  customerEmail : String
  order         : Order
  deriving DecidableEq, Repr

structure Output where
  sentToCustomer : Bool
  emailContent   : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.customerEmail ≠ ""
  post := fun i o => (o.sentToCustomer = true ↔
    i.customerEmail = i.order.details) ∧
                     (o.emailContent = i.order.details)

example : Spec.pre { customerEmail := "customer@example.com", order := { id := 1, amount := 10, details := "customer@example.com" } } ∧
          Spec.post { customerEmail := "customer@example.com", order := { id := 1, amount := 10, details := "customer@example.com" } }
                    { sentToCustomer := true, emailContent := "customer@example.com" } := by
  unfold Spec; decide
