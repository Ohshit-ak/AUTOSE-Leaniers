-- 5.5/R2: For returning customers, the system shall validate 'existing' credit card in system after each log in.
-- checked: True

structure Input where
  cardNumber : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (i.cardNumber.length = 16 ∧
     i.cardNumber.toList.all (·.isDigit) = true)

example : Spec.pre { cardNumber := "1234567890123456" } ∧
          Spec.post { cardNumber := "1234567890123456" }
                    { valid := true } := by
  unfold Spec; decide
