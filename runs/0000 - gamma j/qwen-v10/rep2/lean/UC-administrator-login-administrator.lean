import ContractForge
open ContractForge

-- UC-administrator-login-administrator: Login Administrator: Login to an Administrator account with the system.
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
    i.username = "admin" ∧ i.password = "admin" ∧
    (i.email = "admin@example.com" ∨ (o.cookie = "reset" ∧ i.email ≠ "")))
    ∧ o.cookie = "session"

example : Spec.pre { username := "admin", password := "admin", email := "admin@example.com" } ∧ Spec.post { username := "admin", password := "admin", email := "admin@example.com" } { loggedIn := true, cookie := "session" } := by
  unfold Spec; decide
