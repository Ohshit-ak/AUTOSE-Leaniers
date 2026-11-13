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
      (a.failedAttempts = 3 ∨ a.failedAttempts > 3 ∧ a.password ≠ i.password)) ∧
    ∀ a ∈ o.accounts, a.failedAttempts = a.failedAttempts + (if o.accepted then 0 else 1)

example : Spec.pre { accounts := [{ username := "user1", password := "pw1", failedAttempts := 2 }], username := "user1", password := "pw1" } ∧ Spec.post { accounts := [{ username := "user1", password := "pw1", failedAttempts := 2 }], username := "user1", password := "pw1" } { accounts := [{ username := "user1", password := "pw1", failedAttempts := 2 }], accepted := true } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  accepted : Bool
  accounts : List Account
  deriving DecidableEq, Repr

def AuthenticateUserContract : Contract Input Mid where
  pre  := fun i => i.username ≠ ""
  post := fun i m => m.accepted = true ↔
                     ∃ a ∈ i.accounts, a.username = i.username ∧
                     (a.failedAttempts < 3 ∧ a.password = i.password) ∧
                     ∀ a ∈ m.accounts, a.failedAttempts = a.failedAttempts + (if m.accepted then 0 else 1)

def UpdateAccountsContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.accepted = m.accepted ∧
                     o.accounts = m.accounts.filter (fun a => a.failedAttempts < 3) ++ m.accounts.filter (fun a => a.failedAttempts = 3)
