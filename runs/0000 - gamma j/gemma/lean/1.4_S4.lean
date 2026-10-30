-- 1.4/S4: The minimum total inventory will be 20,000 items.
-- checked: True

structure Input where
  inventory_count : Nat

structure Output where
  is_compliant : Bool

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => (o.is_compliant = true) ↔ (20000 ≤ i.inventory_count)

example : Spec.pre ⟨25000⟩ ∧ Spec.post ⟨25000⟩ ⟨true⟩ := by
  constructor
  · trivial
  · simp [Spec]
