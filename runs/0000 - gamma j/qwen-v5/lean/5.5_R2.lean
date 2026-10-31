-- 5.5/R2: For returning customers, the system shall validate 'existing' credit card in system after each log in.
-- checked: True

structure Input where
  creditCardNumber : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (i.creditCardNumber.length = 16 ∧
     i.creditCardNumber.toList.all (·.isDigit) = true)

example : Spec.pre { creditCardNumber := "1234567890123456" } ∧
          Spec.post { creditCardNumber := "1234567890123456" }
                    { valid := true } := by
  unfold Spec; decide
