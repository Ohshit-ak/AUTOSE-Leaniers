-- 5.1/R1: Upon the USB being plugged in the system shall be able to be deployed and operational in less than 1 minute.
-- checked: True

structure Input where
  amount : Nat

structure Output where
  accepted : Bool
  elapsedMicros : Nat

def Spec : Contract Input Output where
  pre  := fun i => i.amount ≤ 1000
  post := fun i o => o.accepted = true ∧ o.elapsedMicros < 60000000

example : Spec.pre ⟨5⟩ ∧ Spec.post ⟨5⟩ ⟨true, 5000000⟩ := by
  simp [Spec]
