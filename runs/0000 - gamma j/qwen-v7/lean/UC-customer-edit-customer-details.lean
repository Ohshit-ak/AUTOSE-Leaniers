import ContractForge
open ContractForge

-- UC-customer-edit-customer-details: Edit Customer Details: Edit the customer account details.
-- compiles: True · rejects_bad_example: None · checked: True

structure Account where
  username : String
  password : String
  details  : String
  deriving DecidableEq, Repr

structure Input where
  signedIn : Bool
  details  : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  details  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => o.signedIn = i.signedIn ∧
                     o.details = i.details

example : Spec.pre { signedIn := true, details := "John Doe" } ∧
          Spec.post { signedIn := true, details := "John Doe" }
                    { signedIn := true, details := "John Doe" } := by
  unfold Spec; decide
