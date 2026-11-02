import ContractForge
open ContractForge

-- 5.3/R3: The system shall encrypt all customer data in database.
-- compiles: True · rejects_bad_example: None · checked: False

structure CustomerData where
  name    : String
  address : String
  phone   : String
  email   : String
  deriving DecidableEq, Repr

structure Input where
  data : List CustomerData
  deriving DecidableEq, Repr

structure Output where
  data : List CustomerData
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.data = i.data ∧
                     ∀ d ∈ o.data, d.name ≠ "" ∧ d.address ≠ "" ∧ d.phone ≠ "" ∧ d.email ≠ ""

example : Spec.pre { data := [{ name := "Alice", address := "123 Elm St", phone := "555-1234", email := "alice@example.com" }] } ∧
          Spec.post { data := [{ name := "Alice", address := "123 Elm St", phone := "555-1234", email := "alice@example.com" }] }
                     { data := [{ name := "Alice", address := "123 Elm St", phone := "555-1234", email := "alice@example.com" }] } := by
  unfold Spec; decide
