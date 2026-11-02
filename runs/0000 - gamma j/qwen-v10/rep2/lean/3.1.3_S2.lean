import ContractForge
open ContractForge

-- 3.1.3/S2: Customers will be able to register, log in, and log out of their accounts.
-- compiles: True · rejects_bad_example: True · checked: True

structure Account where
  username : String
  password : String
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  registered : Bool
  accounts : List Account
  failedAttempts : Nat
  deriving DecidableEq, Repr

structure Output where
  logged : Bool
  failedAttempts : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.registered = true ∧ i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o =>
    (o.logged = true ↔
      i.registered = true ∧
      ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password) ∧
    o.failedAttempts = i.failedAttempts + (if o.logged = false then 1 else 0)

example : Spec.pre { username := "john", password := "pass123", registered := true,
                     accounts := [{ username := "john", password := "pass123" }],
                     failedAttempts := 0 } ∧
          Spec.post { username := "john", password := "pass123", registered := true,
                      accounts := [{ username := "john", password := "pass123" }],
                      failedAttempts := 0 }
                    { logged := true, failedAttempts := 0 } := by
  unfold Spec; decide

example : Spec.pre { username := "john", password := "wrong", registered := true,
                     accounts := [{ username := "john", password := "pass123" }],
                     failedAttempts := 0 } ∧
          Spec.post { username := "john", password := "wrong", registered := true,
                      accounts := [{ username := "john", password := "pass123" }],
                      failedAttempts := 0 }
                    { logged := false, failedAttempts := 1 } := by
  unfold Spec; decide
