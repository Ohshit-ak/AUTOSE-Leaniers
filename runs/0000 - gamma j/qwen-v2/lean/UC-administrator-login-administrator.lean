-- UC-administrator-login-administrator: Login Administrator: Login to an Administrator account with the system.
-- checked: True

structure Input where
  username : String
  password : String
  deriving DecidableEq, Repr

structure Output where
  logged : Bool
  cookie : Option String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username.length > 0 ∧ i.password.length > 0
  post := fun i o => o.logged = true ∧
                     (o.cookie.isSome ↔ i.username = "admin" ∧ i.password = "admin123")

example : Spec.pre { username := "admin", password := "admin123" } ∧
          Spec.post { username := "admin", password := "admin123" }
                     { logged := true, cookie := some "session123" } := by
  unfold Spec; decide
