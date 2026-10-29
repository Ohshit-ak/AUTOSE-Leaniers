-- 5.1/R7: The system shall be able to validate credit card in less than 2 seconds.
-- checked: None

structure CreditCardInfo where
  cardNumber : String
  -- Add other fields as necessary

structure Output where
  isValid : Bool
  elapsedMicros : Nat

def Spec : Contract CreditCardInfo Output where
  pre info := true
  post info out := out.elapsedMicros < 2000000

example : Spec (CreditCardInfo.mk "1234567890123456") (Output.mk true 1000000) := by
  decide

example : Spec (CreditCardInfo.mk "1234567890123456") (Output.mk true 2500000) := by
  decide
