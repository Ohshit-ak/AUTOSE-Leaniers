import ContractForge
open ContractForge

-- 5.3/R3: The system shall encrypt all customer data in database.
-- compiles: True · rejects_bad_example: False · checked: False

structure Input where
  customerData : List String
  deriving DecidableEq, Repr

structure Output where
  customerData : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.customerData = i.customerData ∧
                     (i.customerData.all (fun s => s.toList.all (fun c => c.isAlpha)) = 
                      o.customerData.all (fun s => s.toList.all (fun c => c.isAlpha)))

example : Spec.pre { customerData := ["name", "address"] } ∧
          Spec.post { customerData := ["name", "address"] }
                     { customerData := ["name", "address"] } := by
  unfold Spec; decide
