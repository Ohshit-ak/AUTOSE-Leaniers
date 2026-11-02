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
  accounts : List Account
  username : String
  password : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  cookie   : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧
                   ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password
  post := fun i o => o.signedIn = true ∧
                     (o.cookie = "" ↔ ∃ a ∈ i.accounts, a.username = i.username) ∧
                     (o.cookie ≠ "" → o.signedIn = true)

example : Spec.pre { accounts := [{ username := "john", password := "pass123", email := "john@example.com" }], username := "john", password := "pass123" } ∧ Spec.post { accounts := [{ username := "john", password := "pass123", email := "john@example.com" }], username := "john", password := "pass123" } { signedIn := true, cookie := "" } := by
  unfold Spec; decide
