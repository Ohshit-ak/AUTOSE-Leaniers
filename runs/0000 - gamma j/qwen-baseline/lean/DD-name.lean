-- DD-name: Name of the customer; maximum 100 alphabetic characters
-- checked: False

structure Input where
  name : String

structure Output where
  valid : Bool

def is_valid_name (s : String) : Prop :=
  s.length ≤ 100 ∧ s.forall (fun c => c.isAlpha)

def Spec : Contract Input Output where
  pre  := fun i => is_valid_name i.name
  post := fun i o => o.valid = true ↔ is_valid_name i.name

example : Spec.pre ⟨"JohnDoe"⟩ ∧ Spec.post ⟨"JohnDoe"⟩ ⟨true⟩ := by
  simp [Spec]
