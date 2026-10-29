-- DD-text-description: special description of the selected item; maximum 100 alphabetic characters
-- checked: None

structure Contract (α β : Type) where
  pre  : α → Prop
  post : α → β → Prop

def TextDescription : Type := String

def Spec : Contract TextDescription Bool where
  pre t := t.length ≤ 100 ∧ ∀ i in finset.range t.length, isAlpha (t[i])
  post t v := v ∧ pre t

example : Spec "short" true := by
  simp [Spec.post, Spec.pre]

example : ¬ Spec "too long description that exceeds 100 characters" true := by
  simp [Spec.post, Spec.pre]
