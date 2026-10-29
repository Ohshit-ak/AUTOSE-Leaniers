-- DD-user-id: User ID of the employee /customer of Tool Co Company; minimum 4 to maximum 10 characters (alphabetic or alphanumeric)
-- checked: None

structure Contract (α β : Type) where
  pre  : α → Prop
  post : α → β → Prop

inductive UserID : String → Prop
| valid (s : String) (h : 4 ≤ String.length s ∧ String.length s ≤ 10 ∧ ∀ i, i < String.length s → s[i] ∈ 'a' 'A' 'b' 'B' 'c' 'C' 'd' 'D' 'e' 'E' 'f' 'F' 'g' 'G' 'h' 'H' 'i' 'I' 'j' 'J' 'k' 'K' 'l' 'L' 'm' 'M' 'n' 'N' 'o' 'O' 'p' 'P' 'q' 'Q' 'r' 'R' 's' 'S' 't' 'T' 'u' 'U' 'v' 'V' 'w' 'W' 'x' 'X' 'y' 'Y' 'z' 'Z') :
  UserID s

def Spec : Contract String UserID where
  pre s := UserID.valid s
  post s u := UserID.valid s

example : Spec "AbcD" UserID.valid := by
  simp [Spec]
  exact UserID.valid "AbcD"

example : ¬ Spec "Abc" UserID.valid := by
  simp [Spec]
  exact dec_trivial

example : ¬ Spec "AbcD123456" UserID.valid := by
  simp [Spec]
  exact dec_trivial
