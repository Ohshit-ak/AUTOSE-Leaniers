-- DD-name: Name of the customer; maximum 100 alphabetic characters
-- checked: None

structure Contract (α β : Type) where
  pre  : α → Prop
  post : α → β → Prop

inductive Name : Type
| mk : String → Name
| invalid : String → Name

def max_length := 100

def is_alphabetic (s : String) : Prop :=
  ∀ i < s.length, Char.isLetter (s[i])

def valid_name (n : Name) : Prop :=
  match n with
  | Name.mk s => s.length ≤ max_length ∧ is_alphabetic s
  | Name.invalid _ => False

def Spec : Contract Name Bool :=
  { pre := λ n, valid_name n
  , post := λ n res, res }
example : Spec.pre (Name.mk "JohnDoe") := by
  simp [valid_name, is_alphabetic]
example : ¬ Spec.pre (Name.mk "JohnDoe123") := by
  simp [valid_name, is_alphabetic]
example : ¬ Spec.pre (Name.invalid "JohnDoe") := by
  simp [valid_name]
