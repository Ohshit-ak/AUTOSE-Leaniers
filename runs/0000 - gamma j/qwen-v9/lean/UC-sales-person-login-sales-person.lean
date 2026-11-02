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
  cookie   : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ i.email ≠ ""
  post := fun i o => (o.loggedIn = true ↔
    (i.username = "registered_username" ∧ i.password = "registered_password" ∧
     i.email = "registered_email")) ∧
    (o.loggedIn = false →
     (i.username = "registered_username" ∧ i.password ≠ "registered_password" ∧
      i.email = "registered_email" → o.cookie = "reset_email_cookie"))

example : Spec.pre { username := "john_doe", password := "password123", email := "john@example.com" } ∧ Spec.post { username := "john_doe", password := "password123", email := "john@example.com" } { loggedIn := false, cookie := "session_cookie" } := by
  unfold Spec; decide
