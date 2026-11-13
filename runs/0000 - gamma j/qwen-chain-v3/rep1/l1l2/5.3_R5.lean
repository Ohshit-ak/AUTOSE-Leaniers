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

-- L1 architecture (mode=chain, success=False)

structure Mid where
  account : Option Account
  failedAttempts : Nat
  accepted : Bool
  accounts : List Account
  deriving DecidableEq, Repr

def CheckAccountContract : Contract Input Mid where
  pre  := fun i => i.username ≠ ""
  post := fun i m =>
    m.account = some (a : Account) ∧
    a.username = i.username ∧
    (m.failedAttempts = a.failedAttempts ∧
     (m.accepted = true ↔ a.password = i.password ∧ a.failedAttempts < 3)) ∧
    (m.accepted = false ↔ a.failedAttempts = 3 ∨ a.failedAttempts + 1 = 3) ∧
    m.accounts = i.accounts

def UpdateAccountContract : Contract Mid Output where
  pre  := fun m => m.account ≠ none
  post := fun m o =>
    (o.accepted = true ↔ m.accepted = true) ∧
    (o.accepted = false ↔ m.accepted = false) ∧
    o.accounts = m.accounts.map (fun a =>
      if a.username = m.account.get!.username then
        { a with failedAttempts := m.account.get!.failedAttempts + 1 }
      else
        a)
