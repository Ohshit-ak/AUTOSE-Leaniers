import ContractForge
open ContractForge

-- 5.3/R3: The system shall encrypt all customer data in database.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  customerData : List String
  deriving DecidableEq, Repr

structure Output where
  encryptedData : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.encryptedData = i.customerData.map (fun s => "encrypted-" ++ s)

example : Spec.pre { customerData := ["name", "address", "phone"] } ∧
          Spec.post { customerData := ["name", "address", "phone"] }
                     { encryptedData := ["encrypted-name", "encrypted-address", "encrypted-phone"] } := by
  unfold Spec; decide
