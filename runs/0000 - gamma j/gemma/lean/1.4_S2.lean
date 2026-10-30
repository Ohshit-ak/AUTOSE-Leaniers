-- 1.4/S2: The initial inventory will be 100 items.
-- checked: True

structure Input where
  items : Nat

structure Output where
  items : Nat

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.items = 100

example : Spec.pre ⟨0⟩ ∧ Spec.post ⟨0⟩ ⟨100⟩ := by
  simp [Spec]
