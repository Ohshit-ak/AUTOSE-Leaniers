-- 3.1.3/S2: Customers will be able to register, log in, and log out of their accounts.
-- checked: False

structure Input where
  action : String
  deriving DecidableEq, Repr

structure Output where
  logged_in : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.logged_in = true ↔
    (i.action = "register" ∨
     (i.action = "login" ∧ o.logged_in = false) ∨
     (i.action = "logout" ∧ o.logged_in = true))

example : Spec.pre { action := "login" } ∧
          Spec.post { action := "login", action := "login", logged_in := false } { logged_in := true } := by
  unfold Spec; decide
