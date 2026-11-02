import ContractForge
open ContractForge

-- UC-customer-register-customer: Register Customer: Register a new customer account with the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Customer where
  name    : String
  address : String
  email   : String
  phone   : String
  deriving DecidableEq, Repr

structure Input where
  customer : Customer
  cookie   : Option Nat
  deriving DecidableEq, Repr

structure Output where
  registered : Bool
  account    : Customer
  cookie     : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.customer.name ≠ "" ∧ i.customer.email ≠ ""
  post := fun i o => o.registered = true ∧
                     o.account = i.customer ∧
                     o.cookie ≠ 0

example : Spec.pre { customer := { name := "John Doe", address := "123 Main St", email := "john@example.com", phone := "555-1234" },
                     cookie := none } ∧
          Spec.post { customer := { name := "John Doe", address := "123 Main St", email := "john@example.com", phone := "555-1234" },
                      cookie := none }
                    { registered := true, account := { name := "John Doe", address := "123 Main St", email := "john@example.com", phone := "555-1234" }, cookie := 12345 } := by
  unfold Spec; decide
