import ContractForge
open ContractForge

-- 5.3/R3: The system shall encrypt all customer data in database.
-- compiles: True · rejects_bad_example: None · checked: True

structure CustomerData where
  name   : String
  email  : String
  phone  : String
  address: String
  deriving DecidableEq, Repr

structure Input where
  data : List CustomerData
  deriving DecidableEq, Repr

structure Output where
  encryptedData : List CustomerData
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.encryptedData = i.data ∧
                     (∀ d ∈ o.encryptedData, d.name ≠ "" ∧
                      d.email ≠ "" ∧ d.phone ≠ "" ∧ d.address ≠ "")

example : Spec.pre { data := [{ name := "John Doe", email := "john@example.com", phone := "1234567890", address := "123 Main St" }] } ∧
          Spec.post { data := [{ name := "John Doe", email := "john@example.com", phone := "1234567890", address := "123 Main St" }] }
                    { encryptedData := [{ name := "John Doe", email := "john@example.com", phone := "1234567890", address := "123 Main St" }] } := by
  unfold Spec; decide
