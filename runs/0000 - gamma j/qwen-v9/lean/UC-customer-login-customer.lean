import ContractForge
open ContractForge

-- UC-customer-login-customer: Login Customer: Login to a customer account with the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  username : String
  password : String
  deriving DecidableEq, Repr

structure Output where
  logged : Bool
  cookie : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => o.logged = true ∧
                     (o.cookie ≠ "" ↔ i.username = "registered" ∧ i.password = "customer")

example : Spec.pre { username := "registered", password := "customer" } ∧
          Spec.post { username := "registered", password := "customer" }
                    { logged := true, cookie := "session123" } := by
  unfold Spec; decide
