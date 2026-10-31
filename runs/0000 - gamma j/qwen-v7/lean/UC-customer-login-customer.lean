import ContractForge
open ContractForge

-- UC-customer-login-customer: Login Customer: Login to a customer account with the system.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  username : String
  password : String
  cookie   : Option String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  cookie   : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cookie.isNone ∧ i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => o.signedIn = true ↔
    ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password

example : Spec.pre { username := "john", password := "pass123", cookie := none } ∧
          Spec.post { username := "john", password := "pass123", cookie := none }
                    { signedIn := true, cookie := "session-cookie" } := by
  unfold Spec; decide
