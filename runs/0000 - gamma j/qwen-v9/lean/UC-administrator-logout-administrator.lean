import ContractForge
open ContractForge

-- UC-administrator-logout-administrator: Logout Administrator: Logout the Administrator account on the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Session where
  cookie : String
  deriving DecidableEq, Repr

structure Input where
  logged_in : Bool
  cookie    : String
  deriving DecidableEq, Repr

structure Output where
  logged_in : Bool
  cookie    : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.logged_in = true
  post := fun i o => o.logged_in = false ∧ o.cookie = i.cookie

example : Spec.pre { logged_in := true, cookie := "abc123" } ∧
          Spec.post { logged_in := true, cookie := "abc123" }
                    { logged_in := false, cookie := "abc123" } := by
  unfold Spec; decide
