import ContractForge
open ContractForge

-- UC-administrator-logout-administrator: Logout Administrator: Logout the Administrator account on the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Session where
  cookie : String
  deriving DecidableEq, Repr

structure Input where
  cookie : String
  logged : Bool
  deriving DecidableEq, Repr

structure Output where
  cookie : String
  logged : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.logged = true
  post := fun i o => o.logged = false ∧ o.cookie = i.cookie

example : Spec.pre { cookie := "abc123", logged := true } ∧
          Spec.post { cookie := "abc123", logged := true }
                    { logged := false, cookie := "abc123" } := by
  unfold Spec; decide
