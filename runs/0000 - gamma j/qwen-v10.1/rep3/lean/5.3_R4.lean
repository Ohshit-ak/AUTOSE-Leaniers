import ContractForge
open ContractForge

-- 5.3/R4: The system shall auto detect IP DOS attacks and block IP automatically.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  ip : String
  failedAttempts : Nat
  deriving DecidableEq, Repr

structure Output where
  ip : String
  blocked : Bool
  failedAttempts : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.failedAttempts < 10
  post := fun i o => (o.blocked = true ↔ i.failedAttempts ≥ 5) ∧
                     o.failedAttempts = i.failedAttempts + 1

example : Spec.pre { ip := "192.168.1.1", failedAttempts := 4 } ∧ Spec.post { ip := "192.168.1.1", failedAttempts := 4 } { ip := "192.168.1.1", blocked := false, failedAttempts := 5 } := by
  unfold Spec; decide
