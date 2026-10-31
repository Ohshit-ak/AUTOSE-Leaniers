-- DD-credit-card-no: Credit card number of the customer; 16 digit numeric string
-- checked: False

structure Input where
  creditCardNo : Nat

structure Valid where
  creditCardNo : Nat
  exactLength : creditCardNo = 16
  numeric : ∀ i : Nat, i < 16 → 0 ≤ Nat.mod (creditCardNo / 10^i) 10

def Spec : Contract Input Valid where
  pre  := fun i => i.creditCardNo < 10^16
  post := fun i v => v.exactLength ∧ v.numeric

example : Spec.pre ⟨1234567890123456⟩ ∧ Spec.post ⟨1234567890123456⟩ ⟨1234567890123456, true, fun i hi => 0 ≤ Nat.mod (1234567890123456 / 10^i) 10⟩ := by
  simp [Spec]
  exact ⟨true, fun i hi => 0 ≤ Nat.mod (1234567890123456 / 10^i) 10⟩
