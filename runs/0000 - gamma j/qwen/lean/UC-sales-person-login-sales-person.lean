-- UC-sales-person-login-sales-person: Login Sales Person: Login to an account with the system.
-- checked: False

structure Input where
  username : String
  password : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  cookie   : Option String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => o.signedIn = true ∧
                     (o.cookie.isSome → i.username = o.cookie.get)
                     ∧
                     (o.cookie.isNone → o.signedIn = false)

example : Spec.pre { username := "salesperson", password := "password123" } ∧
          Spec.post { username := "salesperson", password := "password123" }
                    { signedIn := true, cookie := some "session_cookie" } := by
  unfold Spec; decide
