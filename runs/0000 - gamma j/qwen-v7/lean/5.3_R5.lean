import ContractForge
open ContractForge

-- 5.3/R5: The system shall detect consecutive failed login attempts.
-- compiles: True · rejects_bad_example: None · checked: True

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
  username : String
  password : String
  failedAttempts : Nat
  signedIn : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ ""
  post := fun i o => (o.signedIn = true ↔
    ∃ a ∈ i.accounts, a.username = i.username ∧
    (o.failedAttempts = a.failedAttempts + 1 ∨ o.failedAttempts = a.failedAttempts))
    ∧ o.failedAttempts ≤ 5

example : Spec.pre { accounts := [{ username := "user1", password := "pass1", failedAttempts := 1 }], username := "user1", password := "pass1" } ∧ Spec.post { accounts := [{ username := "user1", password := "pass1", failedAttempts := 1 }], username := "user1", password := "pass1" } { accounts := [{ username := "user1", password := "pass1", failedAttempts := 1 }], username := "user1", password := "pass1", failedAttempts := 1, signedIn := true } := by
  unfold Spec; decide
