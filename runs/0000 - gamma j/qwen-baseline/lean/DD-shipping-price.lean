-- DD-shipping-price: Cost for shipping the item to its destination; in dollars and cents
-- checked: False

structure Input where
  shippingPrice : Nat

structure Output where
  valid : Bool

def Spec : Contract Input Output where
  pre  := fun i => i.shippingPrice ≤ 100
  post := fun i o => o.valid = true ↔ i.shippingPrice ≤ 100 ∧ i.shippingPrice % 100 = 0

example : Spec.pre ⟨50⟩ ∧ Spec.post ⟨50⟩ ⟨true⟩ := by
  simp [Spec]
