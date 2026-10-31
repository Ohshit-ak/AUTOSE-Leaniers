import ContractForge
open ContractForge

-- 5.3/R3: The system shall encrypt all customer data in database.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  customerData : List String
  deriving DecidableEq, Repr

structure Output where
  customerData : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => true
  post := fun i o => o.customerData = i.customerData ∧
                     o.customerData.all (fun s => s.length = i.customerData.length)

example : Spec.pre { customerData := [] } ∧ Spec.post { customerData := [] } { customerData := [] } := by
  unfold Spec; decide
