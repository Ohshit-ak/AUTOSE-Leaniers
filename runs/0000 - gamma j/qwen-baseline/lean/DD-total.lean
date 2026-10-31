-- DD-total: Cost of a single unit of the selected item Number of units of that item selected; in dollars and cents
-- checked: False

structure Input where
  total : Nat

def isMoneyCents (n : Nat) : Prop :=
  n ≤ 9999

def Spec : Contract Input Bool where
  pre  := fun i => isMoneyCents i.total
  post := fun i b => b ↔ isMoneyCents i.total

example : Spec.pre ⟨1234⟩ ∧ Spec.post ⟨1234⟩ True := by
  simp [Spec]
