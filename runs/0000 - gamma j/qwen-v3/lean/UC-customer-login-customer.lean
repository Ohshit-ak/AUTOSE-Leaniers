-- UC-customer-login-customer: Login Customer: Login to a customer account with the system.
-- checked: False

structure Input where
  signedIn : Bool
  enteredInfo : String
  incorrectInfo : Bool
  email : String
  emailSent : Bool
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  sessionCookie : Option Nat
  emailSent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = false ∧ i.email.isEmpty = false
  post := fun i o => o.signedIn = true ∧
                     (o.sessionCookie.isSome ↔ i.emailSent = false) ∧
                     (i.emailSent = true ↔ o.emailSent = true)

example : Spec.pre { signedIn := false, enteredInfo := "test", incorrectInfo := false, email := "test@example.com", emailSent := false } ∧
          Spec.post { signedIn := false, enteredInfo := "test", incorrectInfo := false, email := "test@example.com", emailSent := false }
                    { signedIn := true, sessionCookie := none, emailSent := false } := by
  unfold Spec; decide

example : Spec.pre { signedIn := false, enteredInfo := "test", incorrectInfo := true, email := "test@example.com", emailSent := true } ∧
          Spec.post { signedIn := false, enteredInfo := "test", incorrectInfo := true, email := "test@example.com", emailSent := true }
                    { signedIn := true, sessionCookie := none, emailSent := true } := by
  unfold Spec; decide
