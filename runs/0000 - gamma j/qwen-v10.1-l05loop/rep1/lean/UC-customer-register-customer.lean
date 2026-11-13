import ContractForge
open ContractForge

-- UC-customer-register-customer: Register Customer: Register a new customer account with the system.
-- compiles: True · rejects_bad_example: None · checked: True

structure Customer where
  name   : String
  email  : String
  deriving DecidableEq, Repr

structure Input where
  name   : String
  email  : String
  deriving DecidableEq, Repr

structure Output where
  name   : String
  email  : String
  cookie : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ i.email ≠ "" ∧ i.email.toList.all Char.isLower = true
  post := fun i o => o.name = i.name ∧ o.email = i.email ∧ o.cookie ≠ ""

example : Spec.pre { name := "John Doe", email := "a" } ∧ Spec.post { name := "John Doe", email := "a" } { name := "John Doe", email := "a", cookie := "abc123" } := by
  unfold Spec; decide
