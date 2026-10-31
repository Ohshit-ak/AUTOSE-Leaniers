-- DD-e-mail-id: E-mail address of the customer who is using the Web order system; 50 characters alphanumeric
-- checked: False

structure Input where
  email : String

structure ValidEmail where
  value : String
  valid : value.forall (· ∈ 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z' 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z' '0' '1' '2' '3' '4' '5' '6' '7' '8' '9') ∧ String.length value = 50

def Spec : Contract Input ValidEmail where
  pre  := fun i => String.length i.email = 50
  post := fun i v => v.valid

example : Spec.pre ⟨"a"⟩ ∧ Spec.post ⟨"a"⟩ ⟨"a", true⟩ := by
  simp [Spec]
  constructor
  simp [String.length]
  exact ⟨true, rfl⟩
