-- 5.1/R5: The system shall be able to search for a specified product in less than 1 second.
-- checked: True

structure Input where
  productID : Nat

structure Output where
  accepted : Bool
  elapsedMicros : Nat

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.accepted = true ∧ o.elapsedMicros < 1000000

example : Spec.pre ⟨5⟩ ∧ Spec.post ⟨5⟩ ⟨true, 999999⟩ := by
  simp [Spec]
