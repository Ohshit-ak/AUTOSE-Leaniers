-- 5.3/R1: The system shall validate credit cards against fraud.
-- checked: True

structure Input where
  cardNumber : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  fraud : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (12 ≤ i.cardNumber.length ∧ i.cardNumber.length ≤ 19) ∧
    i.cardNumber.toList.all (·.isDigit) = true ∧
    o.fraud = false

example : Spec.pre { cardNumber := "4111111111111111" } ∧
          Spec.post { cardNumber := "4111111111111111" }
                    { valid := true, fraud := false } := by
  unfold Spec; decide
