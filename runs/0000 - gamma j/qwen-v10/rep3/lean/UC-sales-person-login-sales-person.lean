import ContractForge
open ContractForge

-- UC-sales-person-login-sales-person: Login Sales Person: Login to an account with the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  username : String
  password : String
  email    : String
  deriving DecidableEq, Repr

structure Output where
  loggedIn : Bool
  cookie   : Option String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ i.email ≠ ""
  post := fun i o => (o.loggedIn = true ↔
    i.username = "registered_username" ∧ i.password = "registered_password" ∧
    i.email = "registered_email") ∧
    (o.loggedIn = false → o.cookie = some "session_cookie")

example : Spec.pre { username := "registered_username", password := "registered_password", email := "registered_email" } ∧
          Spec.post { username := "registered_username", password := "registered_password", email := "registered_email" }
                    { loggedIn := true, cookie := some "session_cookie" } := by
  unfold Spec; decide
