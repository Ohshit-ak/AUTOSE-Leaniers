import ContractForge
open ContractForge

-- UC-customer-login-customer: Login Customer: Login to a customer account with the system.
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  username : String
  password : String
  email    : String
  cookie   : Option String
  deriving DecidableEq, Repr

structure Output where
  loggedIn : Bool
  cookie   : Option String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ i.email ≠ ""
  post := fun i o => (o.loggedIn = true ↔
    (o.cookie.isSome → true) ∨
    (o.cookie.isNone ∧
      (i.username = "customer" ∧ i.password = "password" ∧
       i.email = "customer@example.com" → true)))

example : Spec.pre { username := "customer", password := "password", email := "customer@example.com", cookie := none } ∧
          Spec.post { username := "customer", password := "password", email := "customer@example.com", cookie := some "session-cookie" }
                    { loggedIn := true, cookie := some "session-cookie" } := by
  unfold Spec; decide
