import ContractForge
open ContractForge

-- UC-customer-login-customer: Login Customer: Login to a customer account with the system.
-- compiles: False · rejects_bad_example: None · checked: False

structure Account where
  username : String
  password : String
  email    : String
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  email    : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  cookie   : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.email ≠ "" ∧ i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => (o.signedIn = true ↔
    ∃ a ∈ i.email, a.username = i.username ∧ a.password = i.password) ∧
    (o.signedIn = false → o.cookie = "")

example : Spec.pre { username := "john", password := "pass123", email := "john@example.com" } ∧
          Spec.post { username := "john", password := "pass123", email := "john@example.com" }
                    { signedIn := true, cookie := "session123" } := by
  unfold Spec; decide
