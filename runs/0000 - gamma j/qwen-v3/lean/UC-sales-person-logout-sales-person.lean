-- UC-sales-person-logout-sales-person: Logout Sales Person: Logout the Sales Person account on the system.
-- checked: True

structure Input where
  logged_in : Bool
  deriving DecidableEq, Repr

structure Output where
  logged_in : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.logged_in = true
  post := fun i o => o.logged_in = false

example : Spec.pre { logged_in := true } ∧
          Spec.post { logged_in := true } { logged_in := false } := by
  unfold Spec; decide
