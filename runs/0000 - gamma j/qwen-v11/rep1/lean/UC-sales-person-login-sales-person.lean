import ContractForge
open ContractForge

-- UC-sales-person-login-sales-person: Login Sales Person: Login to an account with the system.
-- compiles: True · rejects_bad_example: True · checked: True

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
    (o.cookie.isSome → o.cookie.getD "" ≠ "") ∧
    (o.cookie.isNone → i.email.toList.any (· = ' '))) ∧
    (o.loggedIn = false → o.cookie = i.cookie ∧
    (i.cookie.isNone → o.loggedIn = false ∧
    o.cookie = i.cookie ∧
    i.email.toList.any (· = ' ') = true ∧
    i.password.toList.all Char.isAlphanum = true))

example : Spec.pre { username := "salesperson", password := "password123", email := "salesperson@example.com", cookie := none } ∧ Spec.post { username := "salesperson", password := "password123", email := "salesperson@example.com", cookie := none } { loggedIn := true, cookie := some "1234567890" } := by
  unfold Spec; decide
