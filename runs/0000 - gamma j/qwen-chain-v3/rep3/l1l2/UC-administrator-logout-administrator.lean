import ContractForge
open ContractForge

-- UC-administrator-logout-administrator: Logout Administrator: Logout the Administrator account on the system.

-- L0 spec

structure Session where
  cookie : String
  deriving DecidableEq, Repr

structure Input where
  cookie : String
  logged_in : Bool
  deriving DecidableEq, Repr

structure Output where
  cookie : String
  logged_in : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.logged_in = true
  post := fun i o => o.logged_in = false ∧ o.cookie = i.cookie

example : Spec.pre { cookie := "abc123", logged_in := true } ∧
          Spec.post { cookie := "abc123", logged_in := true }
                    { cookie := "abc123", logged_in := false } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  cookie : String
  deriving DecidableEq, Repr

def LogOutContract : Contract Input Mid where
  pre  := fun i => i.logged_in = true
  post := fun i m => m.cookie = i.cookie ∧ m.logged_in = false

def UpdateCookieContract : Contract Mid Output where
  pre  := fun m => m.logged_in = false
  post := fun m o => o.cookie = m.cookie ∧ o.logged_in = m.logged_in
