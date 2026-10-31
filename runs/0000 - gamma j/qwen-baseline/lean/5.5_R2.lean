-- 5.5/R2: For returning customers, the system shall validate 'existing' credit card in system after each log in.
-- checked: True

structure Input where
  customerID : Nat
  creditCardNumber : Nat

structure Output where
  validationSuccess : Bool

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.validationSuccess = true ↔ i.creditCardNumber ≠ 0

example : Spec.pre ⟨123, 4567890123456789⟩ ∧ Spec.post ⟨123, 4567890123456789⟩ ⟨true⟩ := by
  simp [Spec]
