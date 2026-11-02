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

def encrypt (s : String) : String := "s加密" -- Placeholder for actual encryption

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.encryptedData.length = i.customerData.length ∧
                     ∀ s ∈ i.customerData, s ≠ "" →
                     o.encryptedData.contains (encrypt s) = true

example : Spec.pre { customerData := [], encryptedData := ["name加密", "email加密", "address加密"] } ∧ Spec.post { customerData := [], encryptedData := ["name加密", "email加密", "address加密"] } { encryptedData := [] } := by
  unfold Spec; decide
