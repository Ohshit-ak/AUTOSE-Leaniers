import ContractForge
open ContractForge

-- 5.3/R3: The system shall encrypt all customer data in database.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  customerData : List String
  encryptedData : List String
  deriving DecidableEq, Repr

structure Output where
  encryptedData : List String
  deriving DecidableEq, Repr

-- A simple encryption function
def encrypt (s : String) : String := "加密" ++ s

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.encryptedData.length = i.customerData.length ∧
                     ∀ s ∈ i.customerData, s ≠ "" →
                     o.encryptedData.contains (encrypt s) = true

example : Spec.pre { customerData := ["name", "email", "address"], encryptedData := [] } ∧
          Spec.post { customerData := ["name", "email", "address"], encryptedData := [] }
                     { encryptedData := ["加密name", "加密email", "加密address"] } := by
  unfold Spec; decide
