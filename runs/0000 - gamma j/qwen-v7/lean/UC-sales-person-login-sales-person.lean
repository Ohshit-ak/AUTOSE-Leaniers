import ContractForge
open ContractForge

-- UC-sales-person-login-sales-person: Login Sales Person: Login to an account with the system.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  username : String
  password : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  cookie   : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => o.signedIn = true ∧
    (o.cookie ≠ "" ↔
      ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password)

example : Spec.pre { username := "salesperson", password := "correctpassword" } ∧
          Spec.post { username := "salesperson", password := "correctpassword" }
                    { signedIn := true, cookie := "sessioncookie" } := by
  unfold Spec; decide
