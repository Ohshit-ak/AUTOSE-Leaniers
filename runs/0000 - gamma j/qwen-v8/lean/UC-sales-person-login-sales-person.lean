import ContractForge
open ContractForge

-- UC-sales-person-login-sales-person: Login Sales Person: Login to an account with the system.
-- compiles: True · rejects_bad_example: None · checked: False

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
  cookie   : Option String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.accounts.Nodup ∧
                 ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password
  post := fun i o => o.signedIn = true ∧
                     (o.cookie = some "session-cookie" ↔
                      ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password)

example : Spec.pre { accounts := [{ username := "john", password := "pass1", email := "john@example.com" }],
                     username := "john", password := "pass1" } ∧
          Spec.post { accounts := [{ username := "john", password := "pass1", email := "john@example.com" }],
                      username := "john", password := "pass1" }
                    { signedIn := true, cookie := some "session-cookie" } := by
  unfold Spec; decide
