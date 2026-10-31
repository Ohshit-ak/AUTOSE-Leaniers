-- 5.1/R3: The system shall be able to retrieve 200 products per second.
-- checked: True

structure Input where
  amount : Nat

structure Output where
  accepted : Bool
  perSecond : Nat

def Spec : Contract Input Output where
  pre  := fun i => i.amount ≤ 1000
  post := fun i o => o.accepted = true ↔ 0 < i.amount ∧ o.perSecond ≥ 200

example : Spec.pre ⟨5⟩ ∧ Spec.post ⟨5⟩ ⟨true, 250⟩ := by
  simp [Spec]
