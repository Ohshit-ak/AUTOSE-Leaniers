-- 1.4/S2: The initial inventory will be 100 items.
-- checked: True

structure Input where
  items : Nat

structure Output where
  inventory : Nat

def Spec : Contract Input Output where
  pre  := fun i => i.items = 100
  post := fun i o => o.inventory = i.items

example : Spec.pre ⟨100⟩ ∧ Spec.post ⟨100⟩ ⟨100⟩ := by
  simp [Spec]
