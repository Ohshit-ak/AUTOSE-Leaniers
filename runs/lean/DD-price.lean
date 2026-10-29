-- DD-price: Cost of a single unit of the selected item; in dollars and cents.
-- checked: None

structure Contract (α : Type) where
  pre  : α → Prop
  post : α → Prop

def Price := Nat

def Spec : Contract Nat Bool where
  pre val := val ≤ 999999
  post val valid := val ≤ 999999 ∧ val % 100 = 0

example : Spec 123456 true := by
  simp [Spec.post]

example : ¬Spec 123457 true := by
  simp [Spec.post]
