import ContractForge
open ContractForge

-- UC-customer-edit-customer-details: Edit Customer Details: Edit the customer account details.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  signedIn : Bool
  changes  : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  changes  : String
  done     : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => o.done = true ∧ o.changes = i.changes ∧ o.signedIn = i.signedIn

example : Spec.pre { signedIn := true, changes := "new details" } ∧
          Spec.post { signedIn := true, changes := "new details" }
                    { signedIn := true, changes := "new details", done := true } := by
  unfold Spec; decide
