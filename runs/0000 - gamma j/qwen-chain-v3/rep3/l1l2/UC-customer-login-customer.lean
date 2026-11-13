import ContractForge
open ContractForge

-- UC-customer-login-customer: Login Customer: Login to a customer account with the system.

-- L0 spec

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

-- L1 architecture (mode=chain, success=False)

structure Mid where
  username : String
  password : String
  email    : String
  account  : Account
  ok       : Bool
  deriving DecidableEq, Repr

def CheckCredentialsContract : Contract Input Mid where
  pre  := fun i => i.email ≠ ""
  post := fun i m => m.username = i.username ∧ m.password = i.password ∧ m.email = i.email ∧ m.account = i.account ∧ m.ok = (i.password = i.account.password)

def GenerateCookieContract : Contract Mid Output where
  pre  := fun m => m.ok
  post := fun m o => (o.logged = true ↔ m.ok = true) ∧ (o.cookie ≠ "" ↔ m.ok = true)
