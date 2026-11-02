import ContractForge
open ContractForge

-- UC-customer-login-customer: Login Customer: Login to a customer account with the system.
-- compiles: True · rejects_bad_example: None · checked: False

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
  message  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => o.signedIn = true ↔
    ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password ∧
    (o.message = "Login successful." ↔ o.signedIn = true) ∧
    (o.message = "Incorrect login information." ↔ o.signedIn = false)

example : Spec.pre { accounts := [{ username := "john", password := "pass123", email := "john@example.com" }], username := "john", password := "pass123" } ∧ Spec.post { accounts := [{ username := "john", password := "pass123", email := "john@example.com" }], username := "john", password := "pass123" } { signedIn := true, message := "Login successful." } := by
  unfold Spec; decide
