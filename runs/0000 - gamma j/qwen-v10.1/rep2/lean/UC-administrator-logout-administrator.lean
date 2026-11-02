import ContractForge
open ContractForge

-- UC-administrator-logout-administrator: Logout Administrator: Logout the Administrator account on the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Session where
  username : String
  deriving DecidableEq, Repr

structure Input where
  logged_in : Bool
  username  : String
  deriving DecidableEq, Repr

structure Output where
  logged_in : Bool
  username  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.logged_in = true
  post := fun i o => o.logged_in = false ∧ o.username = i.username

example : Spec.pre { logged_in := true, username := "admin" } ∧
          Spec.post { logged_in := true, username := "admin" }
                    { logged_in := false, username := "admin" } := by
  unfold Spec; decide
