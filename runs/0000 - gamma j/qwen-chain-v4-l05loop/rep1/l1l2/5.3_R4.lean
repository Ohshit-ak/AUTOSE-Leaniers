import ContractForge
open ContractForge

-- 5.3/R4: The system shall auto detect IP DOS attacks and block IP automatically.

-- L0 spec

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
  post := fun i o => (o.blocked ↔ i.failedAttempts ≥ 10) ∧
                     o.failedAttempts = i.failedAttempts + 1 ∧
                     (o.blocked → o.failedAttempts ≥ 10) ∧
                     (o.blocked → o.ip = i.ip)

example : Spec.pre { ip := "192.168.1.1", failedAttempts := 9 } ∧ Spec.post { ip := "192.168.1.1", failedAttempts := 9 } { ip := "192.168.1.1", blocked := false, failedAttempts := 10 } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  blocked : Bool
  failedAttempts : Nat
  ip : String
  deriving DecidableEq, Repr

def ComputeBlockedContract : Contract Input Mid where
  pre  := fun i => i.failedAttempts < 10
  post := fun i m => m.blocked ↔ i.failedAttempts ≥ 10 ∧ m.failedAttempts = i.failedAttempts + 1 ∧ m.ip = i.ip

def ApplyBlockedContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.blocked = m.blocked ∧ o.failedAttempts = m.failedAttempts ∧
                     (o.blocked → o.failedAttempts ≥ 10) ∧
                     (o.blocked → o.ip = m.ip)
