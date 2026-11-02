import ContractForge
open ContractForge

-- UC-customer-login-customer: Login Customer: Login to a customer account with the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  username : String
  password : String
  deriving DecidableEq, Repr

structure Output where
  logged : Bool
  cookie : String
  emailSent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => (o.logged = true ↔
    (i.username = "registered_username" ∧ i.password = "registered_password")) ∧
    (o.logged = false → o.emailSent = true)

example : Spec.pre { username := "registered_username", password := "registered_password" } ∧
          Spec.post { username := "registered_username", password := "registered_password" }
                    { logged := true, cookie := "session_cookie", emailSent := false } := by
  unfold Spec; decide
