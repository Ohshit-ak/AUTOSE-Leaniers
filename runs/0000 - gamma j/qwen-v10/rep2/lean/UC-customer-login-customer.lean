import ContractForge
open ContractForge

-- UC-customer-login-customer: Login Customer: Login to a customer account with the system.
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
    i.username = "registered_username" ∧ i.password = "registered_password" ∧
    i.email = "registered_email") ∨
    (o.loggedIn = false ∧
     (i.username = "registered_username" ∧ i.password ≠ "registered_password" ∧
      i.email = "registered_email" → o.cookie = "email_confirmation_cookie"))

example : Spec.pre { username := "registered_username", password := "incorrect_password", email := "registered_email" } ∧
          Spec.post { username := "registered_username", password := "incorrect_password", email := "registered_email" } { loggedIn := false, cookie := "email_confirmation_cookie" } := by
  unfold Spec; decide
