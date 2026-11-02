import ContractForge
open ContractForge

-- UC-customer-edit-customer-details: Edit Customer Details: Edit the customer account details.
-- compiles: True · rejects_bad_example: True · checked: True

structure Account where
  username : String
  email    : String
  deriving DecidableEq, Repr

structure Input where
  signedIn : Bool
  username : String
  email    : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  username : String
  email    : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => o.signedIn = i.signedIn ∧
                     o.username = i.username ∧
                     o.email = i.email

example : Spec.pre { signedIn := true, username := "john", email := "john@example.com" } ∧
          Spec.post { signedIn := true, username := "john", email := "john@example.com" }
                    { signedIn := true, username := "john", email := "john@example.com" } := by
  unfold Spec; decide
