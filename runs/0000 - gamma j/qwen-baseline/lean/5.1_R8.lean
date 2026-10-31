-- 5.1/R8: The system shall be able to acquire shipping charges in less than 2 seconds.
-- checked: True

structure Input where
  amount : Nat

structure Output where
  accepted : Bool
  elapsedMicros : Nat

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.accepted = true ∧ o.elapsedMicros < 2000000

example : Spec.pre ⟨5⟩ ∧ Spec.post ⟨5⟩ ⟨true, 1999999⟩ := by
  simp [Spec]
