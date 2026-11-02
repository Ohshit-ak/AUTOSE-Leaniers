import ContractForge
open ContractForge

-- UC-sales-person-login-sales-person: Login Sales Person: Login to an account with the system.
-- compiles: True · rejects_bad_example: False · checked: False

structure Account where
  username : String
  password : String
  email    : String
  deriving DecidableEq, Repr

structure Input where
  accounts : List Account
  username : String
  password : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  emailSent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.accounts.Nodup ∧
                  ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password
  post := fun i o => o.signedIn = true ∧
                     (o.emailSent ↔
                      ∃ a ∈ i.accounts, a.username = i.username ∧
                      a.password ≠ i.password ∧
                      a.email ≠ "")

example : Spec.pre { accounts := [{ username := "john", password := "pass1", email := "john@example.com" }],
                     username := "john", password := "pass1" } ∧
          Spec.post { accounts := [{ username := "john", password := "pass1", email := "john@example.com" }],
                      username := "john", password := "pass1" }
                    { signedIn := true, emailSent := false } := by
  unfold Spec; decide
