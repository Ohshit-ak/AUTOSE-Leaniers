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
  post := fun i o => (o.blocked = true ↔ i.failedAttempts + 1 ≥ 10) ∧
                     o.failedAttempts = i.failedAttempts + 1

example : Spec.pre { ip := "192.168.1.1", failedAttempts := 9 } ∧
          Spec.post { ip := "192.168.1.1", failedAttempts := 9 }
                    { ip := "192.168.1.1", blocked := true, failedAttempts := 10 } := by
  unfold Spec; decide

-- L1 architect (success=False)

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
  post := fun i o => (o.blocked = true ↔ i.failedAttempts + 1 ≥ 10) ∧
                     o.failedAttempts = i.failedAttempts + 1

-- Component 1: Check if the number of failed attempts is less than 10
def CheckFailedAttemptsContract : Contract Input Input where
  pre  := fun i => i.failedAttempts < 10
  post := fun i i' => i' = i

-- Component 2: Increment the failed attempts and decide if the IP is blocked
def IncrementFailedAttemptsContract : Contract Input Output where
  pre  := fun i => i.failedAttempts < 10
  post := fun i o => o.failedAttempts = i.failedAttempts + 1 ∧
                     (o.blocked = true ↔ i.failedAttempts + 1 ≥ 10)

-- Prove PO1: CheckFailedAttemptsContract's assumption follows from Spec's guarantee
example : Contract.Compatible CheckFailedAttemptsContract Spec := by
  intros i i' o hpre hpost
  rw [hpost] at hpre
  exact hpre

-- Prove PO2: IncrementFailedAttemptsContract refines the composition of CheckFailedAttemptsContract and IncrementFailedAttemptsContract
example : Contract.Refines (CheckFailedAttemptsContract.seq IncrementFailedAttemptsContract) Spec := by
  intros i o hpre hpost
  unfold CheckFailedAttemptsContract IncrementFailedAttemptsContract
  rw [hpre, hpost]
  exact hpost

-- Prove PO1: IncrementFailedAttemptsContract's assumption follows from CheckFailedAttemptsContract's guarantee
example : Contract.Compatible IncrementFailedAttemptsContract CheckFailedAttemptsContract := by
  intros i i' o hpre hpost
  rw [hpre] at hpost
  exact hpost

-- Prove PO2: The composition of CheckFailedAttemptsContract and IncrementFailedAttemptsContract refines Spec
example : Contract.Refines (CheckFailedAttemptsContract.seq IncrementFailedAttemptsContract) Spec := by
  intros i o hpre hpost
  unfold CheckFailedAttemptsContract IncrementFailedAttemptsContract
  rw [hpre, hpost]
  exact hpost

example : Spec.pre { ip := "192.168.1.1", failedAttempts := 9 } ∧
          Spec.post { ip := "192.168.1.1", failedAttempts := 9 }
                    { ip := "192.168.1.1", blocked := true, failedAttempts := 10 } := by
  unfold Spec; decide