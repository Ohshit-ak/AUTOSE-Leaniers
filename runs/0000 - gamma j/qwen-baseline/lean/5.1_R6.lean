-- 5.1/R6: The system shall be able to email customer and vendor in less than 1 second.
-- checked: False

structure Input where
  customerEmail : String
  vendorEmail : String

structure Output where
  accepted : Bool
  elapsedMicros : Nat

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.accepted = true ∧ o.elapsedMicros < 1000000

example : Spec.pre ⟨"customer@example.com", "vendor@example.com"⟩ ∧ Spec.post ⟨"customer@example.com", "vendor@example.com", 500000⟩ := by
  simp [Spec]
