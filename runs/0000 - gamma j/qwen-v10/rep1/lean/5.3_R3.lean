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

-- A simple encryption function (for demonstration purposes)
def encrypt (s : String) : String := s ++ "加密"

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.encryptedData.length = i.customerData.length ∧
                     ∀ s ∈ i.customerData, s ≠ "" →
                     o.encryptedData.contains (encrypt s) = true

example : Spec.pre { customerData := ["name", "email", "address"], encryptedData := ["name加密", "email加密", "address加密"] } ∧
          Spec.post { customerData := ["name", "email", "address"], encryptedData := ["name加密", "email加密", "address加密"] }
                    { encryptedData := ["name加密", "email加密", "address加密"] } := by
  unfold Spec; decide
