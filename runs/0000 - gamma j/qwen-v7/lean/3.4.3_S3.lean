import ContractForge
open ContractForge

-- 3.4.3/S3: The customer will then receive a confirmation email with the specific order details.
-- compiles: True · rejects_bad_example: None · checked: True

structure Order where
  id     : Nat
  details: String
  deriving DecidableEq, Repr

structure Input where
  orderId : Nat
  deriving DecidableEq, Repr

structure Output where
  sent : Bool
  details : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.orderId > 0
  post := fun i o => o.sent ↔ i.orderId = o.details.length

example : Spec.pre { orderId := 123 } ∧ Spec.post { orderId := 123 } { sent := false, details := "123" } := by
  unfold Spec; decide
