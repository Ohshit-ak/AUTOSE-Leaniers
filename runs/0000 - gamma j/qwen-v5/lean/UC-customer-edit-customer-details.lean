-- UC-customer-edit-customer-details: Edit Customer Details: Edit the customer account details.
-- checked: True

structure Input where
  signedIn : Bool
  pending  : Nat
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  pending  : Nat
  done     : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => o.done = true ∧ o.pending = i.pending - 1 ∧ o.signedIn = i.signedIn

example : Spec.pre { signedIn := true, pending := 2 } ∧
          Spec.post { signedIn := true, pending := 2 }
                    { signedIn := true, pending := 1, done := true } := by
  unfold Spec; decide
