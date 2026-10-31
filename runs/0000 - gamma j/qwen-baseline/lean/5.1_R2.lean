-- 5.1/R2: The system shall be able to handle 1000 customers logged in concurrently at the same time.
-- checked: True

structure Input where
  amount : Nat

structure Output where
  accepted : Bool
  concurrentUsers : Nat

def Spec : Contract Input Output where
  pre  := fun i => i.amount ≤ 1000
  post := fun i o => o.accepted = true ∧ o.concurrentUsers ≥ 1000

example : Spec.pre ⟨5⟩ ∧ Spec.post ⟨5⟩ ⟨true, 1000⟩ := by
  simp [Spec]
