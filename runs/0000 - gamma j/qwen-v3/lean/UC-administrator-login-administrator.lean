-- UC-administrator-login-administrator: Login Administrator: Login to an Administrator account with the system.
-- checked: True

structure Input where
  username : String
  password : String
  cookie   : Option String
  deriving DecidableEq, Repr

structure Output where
  logged : Bool
  cookie : Option String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username.length > 0 ∧ i.password.length > 0
  post := fun i o => o.logged = true ∧
                     (i.cookie.isSome → o.cookie = i.cookie) ∧
                     (i.cookie.isNone → o.cookie.isNone)

example : Spec.pre { username := "admin", password := "password123", cookie := none } ∧
          Spec.post { username := "admin", password := "password123", cookie := none }
                     { logged := true, cookie := none } := by
  unfold Spec; decide
