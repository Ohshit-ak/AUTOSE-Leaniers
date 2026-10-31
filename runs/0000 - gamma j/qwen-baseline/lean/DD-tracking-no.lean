-- DD-tracking-no: Number to track the order; 20 characters alphanumeric
-- checked: False

structure Input where
  trackingNo : String

def is_valid_tracking_no (s : String) : Prop where
  exact_length s = 20 ∧
  ∀ i, i < s.length → s[i] ∈ 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z' 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z' '0' '1' '2' '3' '4' '5' '6' '7' '8' '9'

def Spec : Contract Input String where
  pre  := fun i => is_valid_tracking_no i.trackingNo
  post := fun i o => o = i.trackingNo

example : Spec.pre ⟨"ABC1234567890123456"⟩ ∧ Spec.post ⟨"ABC1234567890123456"⟩ "ABC1234567890123456" := by
  simp [Spec]
