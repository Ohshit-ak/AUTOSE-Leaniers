-- DD-state: Name of the state for the above city; maximum 20 characters alphabetic string
-- checked: None

structure Contract (α : Type) where
  pre  : α → Prop
  post : α → Prop

def DDState : Type := String

def max_length (s : DDState) : Prop := s.length ≤ 20

def charset_alphabetic (s : DDState) : Prop := ∀ i in s, 'a' ≤ i ∧ i ≤ 'z'

def Spec : Contract DDState Bool where
  pre s := max_length s ∧ charset_alphabetic s
  post s valid := max_length s ∧ charset_alphabetic s

example : Spec "example" true := by
  simp [Spec]
  exact true
