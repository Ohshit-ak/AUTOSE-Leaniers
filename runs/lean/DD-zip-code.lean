-- DD-zip-code: The postal code of the above address; 5 digit numeric string
-- checked: None

structure Contract (α β : Type) where
  pre  : α → Prop
  post : α → β → Prop

inductive ZipCode : String → Prop
| valid (s : String) (h : s.length = 5 ∧ ∀ i, i < 5 → s[i] ∈ '0' ''9') : ZipCode s

def Spec : Contract String Bool where
  pre raw_value := raw_value.length = 5 ∧ ∀ i, i < 5 → raw_value[i] ∈ '0' ''9'
  post raw_value isValid := isValid ↔ ZipCode.valid raw_value

example : Spec "12345" true := by
  simp [Spec.post, ZipCode.valid]

example : ¬ Spec "123456" true := by
  simp [Spec.post, ZipCode.valid]

example : ¬ Spec "abcde" true := by
  simp [Spec.post, ZipCode.valid]
