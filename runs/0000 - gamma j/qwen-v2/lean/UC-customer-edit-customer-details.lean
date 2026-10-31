-- UC-customer-edit-customer-details: Edit Customer Details: Edit the customer account details.
-- checked: True

structure Input where
  signedIn : Bool
  details  : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  details  : String
  changed  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => o.changed = true ∧ o.details = i.details ∧ o.signedIn = i.signedIn

example : Spec.pre { signedIn := true, details := "John Doe" } ∧
          Spec.post { signedIn := true, details := "John Doe" }
                    { signedIn := true, details := "John Doe", changed := true } := by
  unfold Spec; decide
