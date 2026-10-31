-- DD-text-description: special description of the selected item; maximum 100 alphabetic characters
-- checked: False

structure Input where
  text_description : String

def is_valid_text_description (s : String) : Prop :=
  s.length ≤ 100 ∧ ∀ i, i < s.length → s[i] ∈ 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z'

def Spec : Contract Input Bool where
  pre  := fun i => is_valid_text_description i.text_description
  post := fun i _ => True

example : Spec.pre ⟨"short description"⟩ ∧ Spec.post ⟨"short description"⟩ True := by
  simp [Spec]
