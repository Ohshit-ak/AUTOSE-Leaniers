import ContractForge
open ContractForge

-- UC-sales-person-logout-sales-person: Logout Sales Person: Logout the Sales Person account on the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Session where
  cookie : String
  deriving DecidableEq, Repr

structure Input where
  signedIn : Bool
  cookie   : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  cookie   : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => o.signedIn = false ∧ o.cookie = i.cookie

example : Spec.pre { signedIn := true, cookie := "abc123" } ∧
          Spec.post { signedIn := true, cookie := "abc123" }
                    { signedIn := false, cookie := "abc123" } := by
  unfold Spec; decide
