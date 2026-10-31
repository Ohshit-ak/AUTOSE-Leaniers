-- 5.3/R4: The system shall auto detect IP DOS attacks and block IP automatically.
-- checked: True

structure Input where
  ip : String
  requestCount : Nat

structure Output where
  blocked : Bool

def Spec : Contract Input Output where
  pre  := fun i => i.requestCount ≥ 100
  post := fun i o => o.blocked = true ↔ i.requestCount ≥ 100

example : Spec.pre ⟨"192.168.1.1", 100⟩ ∧ Spec.post ⟨"192.168.1.1", 100⟩ ⟨true⟩ := by
  simp [Spec]
