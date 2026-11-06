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

structure Mid where
  ip : String
  failedAttempts : Nat
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.failedAttempts < 10
  post := fun i m => m.failedAttempts = i.failedAttempts + 1

def BlockContract : Contract Mid Output where
  pre  := fun m => m.failedAttempts < 10
  post := fun m o => (o.blocked = true ↔ m.failedAttempts + 1 ≥ 10) ∧
                     o.failedAttempts = m.failedAttempts + 1

theorem po1 : Contract.Compatible ValidateContract BlockContract := by
  unfold Contract.Compatible ValidateContract BlockContract
  intro i m _ h
  have : m.failedAttempts = i.failedAttempts + 1, from h.2
  rw this at h
  exact h.1

theorem po2 : Contract.Refines (ValidateContract.seq BlockContract) Spec := by
  unfold Contract.Refines Contract.seq ValidateContract BlockContract Spec
  refine ⟨fun i h => h, ?_⟩
  intro i o _ ⟨m, ⟨hp, hq⟩, ho⟩
  simp only at *
  rw [ho, hp, hq]