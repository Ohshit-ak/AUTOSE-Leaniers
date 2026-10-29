-- DD-password: Password of the employee /customer of Tool Co Company; minimum 4 to maximum 10 characters (alphabetic or alphanumeric)
-- checked: None

structure Contract (α β : Type) where
  pre  : α → Prop
  post : α → β → Prop

inductive Password : Type
| mk : String → Password
with
  pre : String → Prop
  where
    pre s := s.length ≤ 10 ∧ s.length ≥ 4 ∧ s.all (\c, c.isAlphaNum)

def Spec : Contract String Password where
  pre s := s.length ≤ 10 ∧ s.length ≥ 4 ∧ s.all (\c, c.isAlphaNum)
  post s p := p.pre

example : Spec "abc123" := by
  simp [Spec.pre, Spec.post]

example : ¬ Spec "a" := by
  simp [Spec.pre, Spec.post]

example : ¬ Spec "abcde12345" := by
  simp [Spec.pre, Spec.post]

example : Spec "a1b2c3" := by
  simp [Spec.pre, Spec.post]
