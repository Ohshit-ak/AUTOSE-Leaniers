-- UC-administrator-logout-administrator: Logout Administrator: Logout the Administrator account on the system.
-- checked: True

structure Input where
  logged_in : Bool
  deriving DecidableEq, Repr

structure Output where
  logged_in : Bool
  session_terminated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.logged_in = true
  post := fun i o => o.logged_in = false ∧ o.session_terminated = true

example : Spec.pre { logged_in := true } ∧
          Spec.post { logged_in := true } { logged_in := false, session_terminated := true } := by
  unfold Spec; decide
