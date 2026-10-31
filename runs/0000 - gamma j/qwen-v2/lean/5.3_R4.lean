-- 5.3/R4: The system shall auto detect IP DOS attacks and block IP automatically.
-- checked: True

structure Input where
  ipAddr : String
  requestCount : Nat
  threshold : Nat
  deriving DecidableEq, Repr

structure Output where
  blocked : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.requestCount > 0 ∧ i.threshold > 0
  post := fun i o => o.blocked = true ↔ i.requestCount ≥ i.threshold

example : Spec.pre { ipAddr := "192.168.1.1", requestCount := 100, threshold := 50 } ∧
          Spec.post { ipAddr := "192.168.1.1", requestCount := 100, threshold := 50 }
                    { blocked := true } := by
  unfold Spec; decide
