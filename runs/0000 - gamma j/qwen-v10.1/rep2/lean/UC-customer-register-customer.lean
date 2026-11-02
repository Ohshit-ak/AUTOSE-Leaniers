import ContractForge
open ContractForge

-- UC-customer-register-customer: Register Customer: Register a new customer account with the system.
-- compiles: True · rejects_bad_example: False · checked: False

structure Customer where
  name   : String
  email  : String
  phone  : String
  deriving DecidableEq, Repr

structure Input where
  customer : Customer
  cookie   : String
  deriving DecidableEq, Repr

structure Output where
  customer : Customer
  cookie   : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.customer.name ≠ "" ∧ i.customer.email ≠ "" ∧ i.customer.phone ≠ ""
  post := fun i o => o.customer = i.customer ∧
                     o.cookie ≠ ""

example : Spec.pre { customer := { name := "John Doe", email := "johndoe@example.com", phone := "1234567890" },
                     cookie := "abc123" } ∧
          Spec.post { customer := { name := "John Doe", email := "johndoe@example.com", phone := "1234567890" },
                      cookie := "abc123" }
                    { customer := { name := "John Doe", email := "johndoe@example.com", phone := "1234567890" },
                      cookie := "abc123" } := by
  unfold Spec; decide
