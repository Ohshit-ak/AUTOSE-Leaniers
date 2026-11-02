import ContractForge
open ContractForge

-- UC-customer-register-customer: Register Customer: Register a new customer account with the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Customer where
  name : String
  email : String
  deriving DecidableEq, Repr

structure Input where
  name : String
  email : String
  deriving DecidableEq, Repr

structure Output where
  registered : Bool
  cookie : String
  name : String
  email : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ i.email ≠ ""
  post := fun i o => o.registered = true ∧
                     (o.cookie ≠ "" ↔ i.name = o.name ∧ i.email = o.email)

example : Spec.pre { name := "John Doe", email := "johndoe@example.com" } ∧
          Spec.post { name := "John Doe", email := "johndoe@example.com" }
                    { registered := true, cookie := "abc123", name := "John Doe", email := "johndoe@example.com" } := by
  unfold Spec; decide
