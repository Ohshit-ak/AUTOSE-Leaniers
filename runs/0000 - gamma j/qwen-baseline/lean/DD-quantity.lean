-- DD-quantity: the number of units of each selected item that the customer is ordering; default = 1; maximum = quantity presently in inventory
-- checked: False

structure Input where
  quantity : Nat

structure Output where
  pass : Bool

def Spec : Contract Input Output where
  pre  := fun i => 1 ≤ i.quantity ∧ i.quantity ≤ 100
  post := fun i o => o.pass = true ↔ Spec.pre i

example : Spec.pre ⟨5⟩ ∧ Spec.post ⟨⟨5⟩, true⟩ := by
  simp [Spec]
  constructor
  simp [Spec]
