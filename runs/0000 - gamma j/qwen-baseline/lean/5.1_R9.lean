-- 5.1/R9: The system shall be able to restore 1000 records per second.
-- checked: False

structure Input where
  amount : Nat

structure Output where
  accepted : Bool
  perSecond : Nat

def Spec : Contract Input Output where
  pre  := fun i => i.amount ≤ 1000
  post := fun i o => o.accepted = true ∧ o.perSecond ≥ 1000

example : Spec.pre ⟨5⟩ ∧ Spec.post ⟨5⟩ ⟨true⟩ ⟨1200⟩ := by
  simp [Spec]
