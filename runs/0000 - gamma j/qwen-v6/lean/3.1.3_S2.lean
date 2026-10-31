import ContractForge
open ContractForge

-- 3.1.3/S2: Customers will be able to register, log in, and log out of their accounts.
-- compiles: True · rejects_bad_example: None · checked: True

structure Account where
  username : String
  password : String
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
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => 
    (o.signedIn = true ↔
      ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password) ∧
    (o.signedIn = false ↔
      i.action = "logout" ∧
      ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password)

example : Spec.pre { accounts := [{ username := "sam", password := "pw1" }], username := "sam", password := "pw1", action := "login" } ∧ Spec.post { accounts := [{ username := "sam", password := "pw1" }], username := "sam", password := "pw1", action := "login" } { signedIn := true } := by
  unfold Spec; decide
