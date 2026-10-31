import ContractForge
open ContractForge

-- 5.3/R3: The system shall encrypt all customer data in database.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  customerData : List String
  isEncrypted  : Bool
  deriving DecidableEq, Repr

structure Output where
  customerData : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.isEncrypted = true
  post := fun i o => o.customerData = i.customerData ↔
                     i.isEncrypted = true

example : Spec.pre { customerData := [], isEncrypted := true } ∧ Spec.post { customerData := [], isEncrypted := true } { customerData := [] } := by
  unfold Spec; decide
