import ContractForge
open ContractForge

-- UC-customer-register-customer: Register Customer: Register a new customer account with the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Customer where
  name   : String
  email  : String
  deriving DecidableEq, Repr

structure Input where
  customer : Customer
  deriving DecidableEq, Repr

structure Output where
  registered : Bool
  cookie     : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.customer.name ≠ "" ∧ i.customer.email ≠ ""
  post := fun i o => o.registered = true ∧
                     (o.cookie ≠ "" ↔ i.customer.email ≠ "")

example : Spec.pre { customer := { name := "John Doe", email := "johndoe@example.com" } } ∧
          Spec.post { customer := { name := "John Doe", email := "johndoe@example.com" } }
                    { registered := true, cookie := "1234567890abcdef" } := by
  unfold Spec; decide
