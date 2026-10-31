-- UC-customer-login-customer: Login Customer: Login to a customer account with the system.
-- checked: True

structure Input where
  signedIn : Bool
  username : String
  password : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  cookie   : Option String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = false ∧ i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => o.signedIn = true ∧
                     (o.cookie.isSome → i.username = o.cookie.getD "default") ∧
                     (o.cookie.isNone → i.username ≠ o.cookie.getD "default")

example : Spec.pre { signedIn := false, username := "john", password := "pass123" } ∧ Spec.post { signedIn := false, username := "john", password := "pass123" } { signedIn := true, cookie := none } := by
  unfold Spec; decide
