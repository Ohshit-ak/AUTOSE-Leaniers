-- 5.3/R5: The system shall detect consecutive failed login attempts.
-- checked: True

structure Input where
  username : String
  password : String
  attempt  : Nat

structure Output where
  success : Bool
  alert   : Bool

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.alert = true ↔ i.attempt ≥ 3 ∧ o.success = false

example : Spec.pre ⟨"user", "pass", 0⟩ ∧ Spec.post ⟨"user", "pass", 3⟩ ⟨false, true⟩ := by
  simp [Spec]
