import ContractForge
open ContractForge

-- UC-customer-edit-customer-details: Edit Customer Details: Edit the customer account details.
-- compiles: True · rejects_bad_example: True · checked: True

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
  post := fun i o => o.signedIn = i.signedIn ∧ o.details = "new details" ∧
                     (o.signedIn = true → i.details ≠ o.details)

example : Spec.pre { signedIn := true, details := "old details" } ∧
          Spec.post { signedIn := true, details := "old details" }
                    { signedIn := true, details := "new details" } := by
  unfold Spec; decide
