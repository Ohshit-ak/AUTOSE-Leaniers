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
  emailSent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ i.email ≠ ""
  post := fun i o => o.loggedIn = true ∧
                     (o.cookie = some "session-cookie" ↔ true) ∧
                     (o.emailSent = true ↔ i.password ≠ i.password)

example : Spec.pre { username := "jsmith", password := "pass123", email := "jsmith@example.com" } ∧
          Spec.post { username := "jsmith", password := "pass123", email := "jsmith@example.com" }
                    { loggedIn := true, cookie := some "session-cookie", emailSent := false } := by
  unfold Spec; decide
