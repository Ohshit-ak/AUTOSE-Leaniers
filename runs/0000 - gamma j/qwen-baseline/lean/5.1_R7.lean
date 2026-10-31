-- 5.1/R7: The system shall be able to validate credit card in less than 2 seconds.
-- checked: False

structure Input where
  cardNumber : String

structure Output where
  accepted : Bool
  elapsedMicros : Nat

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.accepted = true ↔ 0 < i.cardNumber.length ∧ o.elapsedMicros < 2000000

example : Spec.pre ⟨"1234567890123456"⟩ ∧ Spec.post ⟨"1234567890123456"⟩ ⟨true⟩ ⟨1000000⟩ := by
  simp [Spec]
