-- UC-customer-login-customer: Login Customer: Login to a customer account with the system.
-- checked: False

structure Input where
  username  : String
  password  : String
  cookie    : Option String
  registered: Bool
  deriving DecidableEq, Repr

structure Output where
  logged   : Bool
  cookie   : Option String
  emailSent: Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.registered = true
  post := fun i o => o.logged = true ∧
                     (i.cookie.isSome → o.cookie = i.cookie) ∧
                     (i.cookie.isNone → o.cookie.isNone) ∧
                     (o.emailSent = false ↔ i.cookie.isNone ∧ i.password ≠ "incorrect")

example : Spec.pre { username := "john", password := "1234", cookie := none, registered := true } ∧
          Spec.post { username := "john", password := "1234", cookie := none, registered := true }
                    { logged := true, cookie := none, emailSent := false } := by
  unfold Spec; decide

example : Spec.pre { username := "jane", password := "incorrect", cookie := none, registered := true } ∧
          Spec.post { username := "jane", password := "incorrect", cookie := none, registered := true }
                    { logged := false, cookie := none, emailSent := true } := by
  unfold Spec; decide
