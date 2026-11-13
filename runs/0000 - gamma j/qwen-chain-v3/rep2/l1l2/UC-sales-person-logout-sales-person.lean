import ContractForge
open ContractForge

-- UC-sales-person-logout-sales-person: Logout Sales Person: Logout the Sales Person account on the system.

-- L0 spec

structure Session where
  cookie : String
  deriving DecidableEq, Repr

structure Input where
  cookie : String
  signedIn : Bool
  deriving DecidableEq, Repr

structure Output where
  cookie : String
  signedIn : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => o.signedIn = false ∧ o.cookie = i.cookie

example : Spec.pre { cookie := "abc123", signedIn := true } ∧
          Spec.post { cookie := "abc123", signedIn := true }
                    { signedIn := false, cookie := "abc123" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  cookie : String
  deriving DecidableEq, Repr

def SignOutContract : Contract Input Mid where
  pre  := fun i => i.signedIn = true
  post := fun i m => m.cookie = i.cookie ∧ m.signedIn = false

def ApplyMidContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.cookie = m.cookie ∧ o.signedIn = m.signedIn
