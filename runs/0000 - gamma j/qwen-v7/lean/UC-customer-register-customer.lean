import ContractForge
open ContractForge

-- UC-customer-register-customer: Register Customer: Register a new customer account with the system.
-- compiles: True · rejects_bad_example: None · checked: True

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
  sessionCookie : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ i.email ≠ ""
  post := fun i o => o.registered = true ∧
                     (o.sessionCookie ≠ "" ↔ o.registered = true)

example : Spec.pre { name := "John Doe", email := "johndoe@example.com" } ∧
          Spec.post { name := "John Doe", email := "johndoe@example.com" }
                    { registered := true, sessionCookie := "abc123" } := by
  unfold Spec; decide
