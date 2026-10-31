-- 5.3/R1: The system shall validate credit cards against fraud.
-- checked: True

structure CreditCard where
  number : String
  cvv     : Nat

structure ValidationResult where
  isFraudulent : Bool

structure Input where
  card : CreditCard

structure Output where
  result : ValidationResult

def Spec : Contract Input Output where
  pre  := fun i => i.card.cvv ≤ 999
  post := fun i o => o.result.isFraudulent = true → i.card.cvv = 0

example : Spec.pre ⟨{ number := "1234567890123456", cvv := 0 }⟩ ∧ Spec.post ⟨{ number := "1234567890123456", cvv := 0 }⟩ ⟨{ isFraudulent := true }⟩ := by
  simp [Spec]
