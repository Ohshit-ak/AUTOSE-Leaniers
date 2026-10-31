import ContractForge
open ContractForge

-- UC-sales-person-logout-sales-person: Logout Sales Person: Logout the Sales Person account on the system.
-- compiles: True · rejects_bad_example: None · checked: True

structure Session where
  username : String
  deriving DecidableEq, Repr

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
