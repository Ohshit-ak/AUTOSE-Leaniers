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
  action   : String
  accounts : List Account
  deriving DecidableEq, Repr

structure Output where
  username : String
  logged   : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ i.action ∈ ["register", "login", "logout"]
  post := fun i o =>
    (o.logged = true ↔
      (i.action = "register" →
        ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password) ∧
      (i.action = "login" →
        ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password) ∧
      (i.action = "logout" →
        o.username = i.username))

example : Spec.pre { username := "john", password := "pass123", action := "login",
                     accounts := [{ username := "john", password := "pass123" }] } ∧
          Spec.post { username := "john", password := "pass123", action := "login",
                      accounts := [{ username := "john", password := "pass123" }] }
                    { username := "john", logged := true } := by
  unfold Spec; decide
