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
  pre  := fun i => true
  post := fun i o => o.encryptedData = i.customerData.map (fun s => "encrypted_" ++ s)

example : Spec.pre { customerData := ["name", "email", "address"] } ∧
          Spec.post { customerData := ["name", "email", "address"] }
                     { encryptedData := ["encrypted_name", "encrypted_email", "encrypted_address"] } := by
  unfold Spec; decide
