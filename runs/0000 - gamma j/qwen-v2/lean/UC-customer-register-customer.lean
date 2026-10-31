-- UC-customer-register-customer: Register Customer: Register a new customer account with the system.
-- checked: True

structure Input where
  customerName : String
  email        : String
  password     : String
  cookie      : Option String
  deriving DecidableEq, Repr

structure Output where
  customerName : String
  email        : String
  password     : String
  cookie       : String
  sessionCookie : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cookie.isNone ∧
                  i.email.length > 0 ∧
                  i.password.length > 0
  post := fun i o => o.customerName = i.customerName ∧
                     o.email = i.email ∧
                     o.password = i.password ∧
                     o.cookie ≠ "" ∧
                     o.sessionCookie ≠ ""

example : Spec.pre { customerName := "John Doe", email := "johndoe@example.com", password := "password123", cookie := none } ∧
          Spec.post { customerName := "John Doe", email := "johndoe@example.com", password := "password123", cookie := none }
                    { customerName := "John Doe", email := "johndoe@example.com", password := "password123", cookie := "newcookie", sessionCookie := "session123" } := by
  unfold Spec; decide
