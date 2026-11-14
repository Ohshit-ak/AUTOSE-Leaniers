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
  cookie   : Option String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ i.email ≠ ""
  post := fun i o => (o.loggedIn = true ↔
    i.username = "registeredUsername" ∧ i.password = "registeredPassword" ∧
    i.email = "registeredEmail") ∧
    (o.loggedIn = false →
      (o.cookie = some "cookieValue" ↔ i.username = "incorrectUsername" ∧
       i.password = "incorrectPassword" ∧ i.email = "registeredEmail"))

example : Spec.pre { username := "registeredUsername", password := "registeredPassword", email := "registeredEmail" } ∧
          Spec.post { username := "registeredUsername", password := "registeredPassword", email := "registeredEmail" }
                    { loggedIn := true, cookie := some "cookieValue" } := by
  unfold Spec; decide

example : Spec.pre { username := "incorrectUsername", password := "incorrectPassword", email := "registeredEmail" } ∧
          Spec.post { username := "incorrectUsername", password := "incorrectPassword", email := "registeredEmail" }
                    { loggedIn := false, cookie := some "cookieValue" } := by
  unfold Spec; decide
