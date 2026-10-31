-- 3.1.3/S2: Customers will be able to register, log in, and log out of their accounts.
-- checked: True

structure Input where
  action : String
  deriving DecidableEq, Repr

structure Output where
  success : Bool
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.action ∈ ["register", "login", "logout"]
  post := fun i o => o.success = true ↔
    (i.action = "register" → o.message = "Registration successful")
    ∧ (i.action = "login" → o.message = "Login successful")
    ∧ (i.action = "logout" → o.message = "Logout successful")

example : Spec.pre { action := "register" } ∧
          Spec.post { action := "register" }
                     { success := true, message := "Registration successful" } := by
  unfold Spec; decide

example : Spec.pre { action := "login" } ∧
          Spec.post { action := "login" }
                     { success := true, message := "Login successful" } := by
  unfold Spec; decide

example : Spec.pre { action := "logout" } ∧
          Spec.post { action := "logout" }
                     { success := true, message := "Logout successful" } := by
  unfold Spec; decide
