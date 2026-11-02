import ContractForge
open ContractForge

-- 5.3/R5: The system shall detect consecutive failed login attempts.
-- compiles: True · rejects_bad_example: True · checked: True

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
  signedIn : Bool
  failedAttempts : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => (o.signedIn = true ↔
    ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password ∧
    o.failedAttempts = a.failedAttempts + 1) ∧
    (o.signedIn = false →
    ∃ a ∈ i.accounts, a.username = i.username ∧
    o.failedAttempts = a.failedAttempts + 1)

example : Spec.pre { accounts := [{ username := "user1", password := "pw1", failedAttempts := 0 }],
                     username := "user1", password := "pw1" } ∧
          Spec.post { accounts := [{ username := "user1", password := "pw1", failedAttempts := 0 }],
                      username := "user1", password := "pw1" }
                    { signedIn := true, failedAttempts := 1 } := by
  unfold Spec; decide

example : Spec.pre { accounts := [{ username := "user1", password := "pw1", failedAttempts := 0 }],
                     username := "user1", password := "pw2" } ∧
          Spec.post { accounts := [{ username := "user1", password := "pw1", failedAttempts := 0 }],
                      username := "user1", password := "pw2" }
                    { signedIn := false, failedAttempts := 1 } := by
  unfold Spec; decide
