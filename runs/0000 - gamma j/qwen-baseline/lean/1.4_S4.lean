-- 1.4/S4: The minimum total inventory will be 20,000 items.
-- checked: True

structure Input where
  items : Nat

def Spec : Contract Input Bool where
  pre  := fun i => i.items ≥ 20000
  post := fun i o => o = true ↔ i.items ≥ 20000

example : Spec.pre ⟨20000⟩ ∧ Spec.post ⟨20000⟩ true := by
  simp [Spec]
