import ContractForge
open ContractForge

-- 3.1.3/S2: Customers will be able to register, log in, and log out of their accounts.
-- compiles: True · rejects_bad_example: True · checked: True

structure Account where
  username : String
  password : String
  signedIn : Bool
  deriving DecidableEq, Repr

structure Input where
  accounts : List Account
  username : String
  password : String
  action   : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ i.action ∈ ["register", "login", "logout"]
  post := fun i o => (o.signedIn = true ↔
    (i.action = "register" →
      ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password ∧ a.signedIn = true) ∧
    (i.action = "login" →
      ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password ∧ a.signedIn = true) ∧
    (i.action = "logout" →
      ∃ a ∈ i.accounts, a.username = i.username ∧ a.signedIn = true))

example : Spec.pre { accounts := [{ username := "sam", password := "pw1", signedIn := false }], username := "sam", password := "pw1", action := "login" } ∧ Spec.post { accounts := [{ username := "sam", password := "pw1", signedIn := false }], username := "sam", password := "pw1", action := "login" } { signedIn := false } := by
  unfold Spec; decide
