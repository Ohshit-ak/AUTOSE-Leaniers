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
  accounts : List Account
  username : String
  password : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.accounts.any (fun a => a.username = i.username ∧ a.password = i.password)
  post := fun i o => o.signedIn = true ↔
    (i.accounts.any (fun a => a.username = i.username ∧ a.password = i.password) →
      (i.accounts.filter (fun a => a.username = i.username).map (fun a => a.email).length = 1 ∧
       o.signedIn = true) ∨
      (i.accounts.filter (fun a => a.username = i.username).map (fun a => a.email).length = 0 ∧
       o.signedIn = true))

example : Spec.pre { accounts := [{ username := "john", password := "pass123", email := "john@example.com" }],
                     username := "john", password := "pass123" } ∧
          Spec.post { accounts := [{ username := "john", password := "pass123", email := "john@example.com" }],
                      username := "john", password := "pass123" }
                    { signedIn := true } := by
  unfold Spec; decide
