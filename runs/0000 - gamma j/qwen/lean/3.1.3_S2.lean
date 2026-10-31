-- 3.1.3/S2: Customers will be able to register, log in, and log out of their accounts.
-- checked: True

structure Input where
  action : String
  deriving DecidableEq, Repr

structure Output where
  logged_in : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.action = "register" ∨ i.action = "login" ∨ i.action = "logout"
  post := fun i o => 
    (i.action = "register" → o.logged_in = false) ∧
    (i.action = "login" → o.logged_in = true) ∧
    (i.action = "logout" → o.logged_in = false)

example : Spec.pre { action := "login" } ∧
          Spec.post { action := "login" } { logged_in := true } := by
  unfold Spec; decide
