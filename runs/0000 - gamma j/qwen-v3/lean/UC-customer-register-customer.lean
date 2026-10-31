-- UC-customer-register-customer: Register Customer: Register a new customer account with the system.
-- checked: True

structure Input where
  customerInfo : String
  cookie       : Option String
  deriving DecidableEq, Repr

structure Output where
  registered   : Bool
  accountInfo  : String
  cookie       : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.customerInfo.length ≤ 50 ∧ i.cookie.isNone
  post := fun i o => o.registered = true ∧
                     o.accountInfo.length ≤ 50 ∧
                     o.cookie ≠ "" ∧
                     o.cookie = "session-cookie"

example : Spec.pre { customerInfo := "John Doe", cookie := none } ∧
          Spec.post { customerInfo := "John Doe", cookie := none }
                     { registered := true, accountInfo := "123456", cookie := "session-cookie" } := by
  unfold Spec; decide
