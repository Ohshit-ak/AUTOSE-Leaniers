-- 5.5/R5: The system shall validate email address existence.
-- checked: False

structure Input where
  email : String

structure Output where
  exists : Bool

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.exists = true ↔ Format.isEmail i.email

example : Spec.pre ⟨"test@example.com"⟩ ∧ Spec.post ⟨"test@example.com"⟩ ⟨true⟩ := by
  simp [Spec]
