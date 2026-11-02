import ContractForge
open ContractForge

-- 3.4.3/S3: The customer will then receive a confirmation email with the specific order details.
-- compiles: True · rejects_bad_example: True · checked: True

structure Order where
  id       : Nat
  customer : String
  details  : String
  deriving DecidableEq, Repr

structure Input where
  customer : String
  details  : String
  deriving DecidableEq, Repr

structure Output where
  sent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.customer ≠ "" ∧ i.details ≠ ""
  post := fun i o => o.sent ↔ true

example : Spec.pre { customer := "Alice", details := "1x Coffee, 2x Tea" } ∧
          Spec.post { customer := "Alice", details := "1x Coffee, 2x Tea" }
                    { sent := true } := by
  unfold Spec; decide
