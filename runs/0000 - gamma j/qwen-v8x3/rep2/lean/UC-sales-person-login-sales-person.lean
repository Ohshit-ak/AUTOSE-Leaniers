import ContractForge
open ContractForge

-- UC-sales-person-login-sales-person: Login Sales Person: Login to an account with the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Account where
  username : String
  password : String
  deriving DecidableEq, Repr

structure Input where
  accounts : List Account
  username : String
  password : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  cookie   : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => (o.signedIn = true ↔
    ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password) ∧
                     (o.signedIn = false ↔
                       i.username = "" ∨ i.password = "" ∨
                       ¬(∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password))

example : Spec.pre { accounts := [{ username := "salesperson", password := "correct-password" }], username := "salesperson", password := "correct-password" } ∧
          Spec.post { accounts := [{ username := "salesperson", password := "correct-password" }], username := "salesperson", password := "correct-password" }
                    { signedIn := true, cookie := "valid-cookie" } := by
  unfold Spec; decide

example : Spec.pre { accounts := [{ username := "john", password := "pass123" }], username := "john", password := "wrongpass" } ∧
          Spec.post { accounts := [{ username := "john", password := "pass123" }], username := "john", password := "wrongpass" }
                    { signedIn := false, cookie := "invalid-cookie" } := by
  unfold Spec; decide
