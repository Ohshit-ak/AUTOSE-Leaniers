import ContractForge
open ContractForge

-- UC-administrator-logout-administrator: Logout Administrator: Logout the Administrator account on the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Session where
  user     : String
  logged_in: Bool
  deriving DecidableEq, Repr

structure Input where
  session : Session
  deriving DecidableEq, Repr

structure Output where
  session : Session
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.session.logged_in
  post := fun i o => o.session.logged_in = false ∧
                     o.session.user = i.session.user

example : Spec.pre { session := { user := "admin", logged_in := true } } ∧
          Spec.post { session := { user := "admin", logged_in := true } }
                    { session := { user := "admin", logged_in := false } } := by
  unfold Spec; decide
