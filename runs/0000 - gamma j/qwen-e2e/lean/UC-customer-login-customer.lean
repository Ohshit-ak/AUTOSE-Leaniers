import ContractForge
open ContractForge

-- UC-customer-login-customer: Login Customer: Login to a customer account with the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Account where
  username : String
  password : String
  email    : String
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  email    : String
  account  : Account
  deriving DecidableEq, Repr

structure Output where
  logged : Bool
  cookie : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.email ≠ "" -- Customer account must be registered
  post := fun i o => (o.logged = true ↔ i.password = i.account.password) ∧
                     (o.logged = false ↔ i.password ≠ i.account.password) ∧
                     (o.cookie ≠ "" ↔ o.logged = true)

example : Spec.pre { username := "john", password := "pass123", email := "john@example.com", account := { username := "john", password := "pass123", email := "john@example.com" } } ∧ Spec.post { username := "john", password := "pass123", email := "john@example.com", account := { username := "john", password := "pass123", email := "john@example.com" } } { logged := true, cookie := "abc123" } := by
  unfold Spec; decide
