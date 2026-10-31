import ContractForge
open ContractForge

-- UC-sales-person-login-sales-person: Login Sales Person: Login to an account with the system.
-- compiles: True · rejects_bad_example: None · checked: True

structure Account where
  username : String
  password : String
  email    : String
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  accounts : List Account
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => o.signedIn = true ∧
                     (o.signedIn = true ↔
                      ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password)

example : Spec.pre { username := "john_doe", password := "correct_password", accounts := [{ username := "john_doe", password := "correct_password", email := "john@example.com" }] } ∧
          Spec.post { username := "john_doe", password := "correct_password", accounts := [{ username := "john_doe", password := "correct_password", email := "john@example.com" }] }
                    { signedIn := true } := by
  unfold Spec; decide
