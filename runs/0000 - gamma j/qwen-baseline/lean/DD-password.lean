-- DD-password: Password of the employee /customer of Tool Co Company; minimum 4 to maximum 10 characters (alphabetic or alphanumeric)
-- checked: False

structure Input where
  password : String

structure Output where
  valid : Bool

def is_char_in_range (c : Char) (lo hi : Char) : Prop :=
  c ≥ lo ∧ c ≤ hi

def is_valid (s : String) : Prop :=
  s.length ≤ 10 ∧ s.length ≥ 4 ∧
  ∀ i, i < s.length →
    (is_char_in_range s[i] 'a' 'z' ∨
     is_char_in_range s[i] 'A' 'Z' ∨
     is_char_in_range s[i] '0' '9')

def Spec : Contract Input Output where
  pre  := fun i => is_valid i.password
  post := fun i o => o.valid = true ↔ is_valid i.password

example : Spec.pre ⟨"abc123"⟩ ∧ Spec.post ⟨"abc123"⟩ ⟨true⟩ := by
  simp [Spec]
