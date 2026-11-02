import ContractForge
open ContractForge

-- UC-administrator-logout-administrator: Logout Administrator: Logout the Administrator account on the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Session where
  user : String
  deriving DecidableEq, Repr

structure Input where
  user : String
  logged_in : Bool
  deriving DecidableEq, Repr

structure Output where
  user : String
  logged_in : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.logged_in = true
  post := fun i o => o.logged_in = false

example : Spec.pre { user := "admin", logged_in := true } ∧
          Spec.post { user := "admin", logged_in := true }
                    { user := "admin", logged_in := false } := by
  unfold Spec; decide
