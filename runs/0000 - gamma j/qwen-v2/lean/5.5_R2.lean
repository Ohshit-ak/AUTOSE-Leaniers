-- 5.5/R2: For returning customers, the system shall validate 'existing' credit card in system after each log in.
-- checked: True

structure Input where
  customerId : Nat
  creditCard : String
  deriving DecidableEq, Repr

structure Output where
  isValid : Bool
  message  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.customerId ≠ 0
  post := fun i o => o.isValid = true ↔ i.creditCard.length = 16 ∧
                     i.creditCard.toList.all (·.isDigit) = true

example : Spec.pre { customerId := 1, creditCard := "1234567890123456" } ∧
          Spec.post { customerId := 1, creditCard := "1234567890123456" }
                     { isValid := true, message := "Credit card valid" } := by
  unfold Spec; decide
