-- 5.3/R4: The system shall auto detect IP DOS attacks and block IP automatically.
-- checked: True

structure Input where
  ip : String
  requests : List Nat
  deriving DecidableEq, Repr

structure Output where
  blocked : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.ip.length ≤ 15
  post := fun i o => o.blocked = true ↔ i.requests.length ≥ 100

example : Spec.pre { ip := "192.168.1.1", requests := [100] } ∧ Spec.post { ip := "192.168.1.1", requests := [100] } { blocked := false } := by
  unfold Spec; decide
