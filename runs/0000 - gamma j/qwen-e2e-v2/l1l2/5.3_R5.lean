import ContractForge
open ContractForge

-- 5.3/R5: The system shall detect consecutive failed login attempts.

-- L0 spec

structure Account where
  username : String
  password : String
  failedAttempts : Nat
  deriving DecidableEq, Repr

structure Input where
  accounts : List Account
  username : String
  password : String
  deriving DecidableEq, Repr

structure Output where
  accounts : List Account
  accepted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ ""
  post := fun i o =>
    (o.accepted = true ↔
      ∃ a ∈ i.accounts, a.username = i.username ∧
      (a.failedAttempts < 3 ∧ a.password = i.password)) ∧
    (o.accepted = false →
      ∃ a ∈ i.accounts, a.username = i.username ∧
      (a.failedAttempts = 3 ∨ a.failedAttempts + 1 = 3))

example : Spec.pre { accounts := [{ username := "user1", password := "pw1", failedAttempts := 2 }],
                     username := "user1", password := "pw1" } ∧
          Spec.post { accounts := [{ username := "user1", password := "pw1", failedAttempts := 2 }],
                      username := "user1", password := "pw1" }
                    { accepted := true, accounts := [{ username := "user1", password := "pw1", failedAttempts := 2 }] } := by
  unfold Spec; decide

example : Spec.pre { accounts := [{ username := "user1", password := "pw1", failedAttempts := 2 }],
                     username := "user1", password := "pw2" } ∧
          Spec.post { accounts := [{ username := "user1", password := "pw1", failedAttempts := 2 }],
                      username := "user1", password := "pw2" }
                    { accepted := false, accounts := [{ username := "user1", password := "pw1", failedAttempts := 3 }] } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Mid where
  accounts : List Account
  username : String
  password : String
  accepted : Bool
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.username ≠ ""
  post := fun i m => 
    (m.accepted = true ↔
      ∃ a ∈ i.accounts, a.username = i.username ∧
      (a.failedAttempts < 3 ∧ a.password = i.password)) ∧
    (m.accepted = false →
      ∃ a ∈ i.accounts, a.username = i.username ∧
      (a.failedAttempts = 3 ∨ a.failedAttempts + 1 = 3))

def UpdateContract : Contract Mid Output where
  pre  := fun m => m.accepted
  post := fun m o => o.accepted = m.accepted ∧
                     o.accounts = m.accounts

theorem po1 : Contract.Compatible ValidateContract UpdateContract := by
  unfold Contract.Compatible ValidateContract UpdateContract
  intro i m _ h
  simp only at h
  cases h with h1 h2
  · simp only [h1] at h2
    simp only [h2]
  · simp only [h1] at h2
    simp only [h2]

theorem po2 : Contract.Refines (ValidateContract.seq UpdateContract) Spec := by
  unfold Contract.Refines Contract.seq ValidateContract UpdateContract Spec
  refine ⟨fun i h => h, ?_⟩
  intro i o _ ⟨m, ⟨h1, h2⟩, h3⟩
  simp only at *
  rw [h3, h1, h2]