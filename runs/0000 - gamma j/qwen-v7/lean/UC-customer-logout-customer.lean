import ContractForge
open ContractForge

-- UC-customer-logout-customer: Logout Customer: Logout the customer account on the system.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  signedIn : Bool
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => o.signedIn = false

example : Spec.pre { signedIn := true } ∧
          Spec.post { signedIn := true } { signedIn := false } := by
  unfold Spec; decide
