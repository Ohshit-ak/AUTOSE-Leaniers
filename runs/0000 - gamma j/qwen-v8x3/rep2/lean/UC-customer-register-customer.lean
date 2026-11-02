import ContractForge
open ContractForge

-- UC-customer-register-customer: Register Customer: Register a new customer account with the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  customerName : String
  email        : String
  password     : String
  deriving DecidableEq, Repr

structure Output where
  customerName : String
  email        : String
  password     : String
  registered   : Bool
  cookie       : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.customerName ≠ "" ∧ i.email ≠ "" ∧ i.password ≠ ""
  post := fun i o => o.registered = true ∧
                     o.customerName = i.customerName ∧
                     o.email = i.email ∧
                     o.password = i.password ∧
                     o.cookie ≠ ""

example : Spec.pre { customerName := "John Doe", email := "johndoe@example.com", password := "password123" } ∧
          Spec.post { customerName := "John Doe", email := "johndoe@example.com", password := "password123" }
                    { registered := true, email := "johndoe@example.com", customerName := "John Doe", password := "password123", cookie := "abc123" } := by
  unfold Spec; decide
