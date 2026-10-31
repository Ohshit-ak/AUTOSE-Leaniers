-- 5.3/R1: The system shall validate credit cards against fraud.
-- checked: True

structure Input where
  cardNumber : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  fraudDetected : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (i.cardNumber.length = 16 ∧
     i.cardNumber.toList.all (·.isDigit) = true ∧
     (o.fraudDetected = false → o.valid = true) ∧
     (o.fraudDetected = true → o.valid = false))

example : Spec.pre { cardNumber := "1234567890123456" } ∧
          Spec.post { cardNumber := "1234567890123456" }
                    { valid := true, fraudDetected := false } := by
  unfold Spec; decide
