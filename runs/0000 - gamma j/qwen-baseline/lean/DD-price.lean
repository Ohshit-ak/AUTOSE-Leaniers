-- DD-price: Cost of a single unit of the selected item; in dollars and cents.
-- checked: True

structure Input where
  price : Nat

structure Output where
  valid : Bool

def Spec : Contract Input Output where
  pre  := fun i => i.price ≤ 9999
  post := fun i o => o.valid = true ↔ i.price ≤ 9999 ∧ i.price % 100 = 0

example : Spec.pre ⟨1200⟩ ∧ Spec.post ⟨1200⟩ ⟨true⟩ := by
  simp [Spec]
