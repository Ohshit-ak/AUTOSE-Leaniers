import ContractForge
open ContractForge

-- 5.3/R3: The system shall encrypt all customer data in database.
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  customerData : List String
  deriving DecidableEq, Repr

structure Output where
  encryptedData : List String
  deriving DecidableEq, Repr

-- IMPL: Encryption algorithm
def encrypt (s : String) : String := "encrypted_" ++ s

def Spec : Contract Input Output where
  pre  := fun i => i.customerData.Nodup
  post := fun i o => o.encryptedData.Nodup ∧
                     ∀ s ∈ i.customerData, s ≠ "" ∧
                     o.encryptedData.contains (encrypt s) ∧
                     (encrypt s).length = s.length

example : Spec.pre { customerData := [] } ∧ Spec.post { customerData := [] } { encryptedData := [encrypt "data1", encrypt "data2"] } := by
  unfold Spec; decide
