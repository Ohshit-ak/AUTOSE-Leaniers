-- 5.3/R3: The system shall encrypt all customer data in database.
-- checked: False

structure Input where
  customerData : List String
  deriving DecidableEq, Repr

structure Output where
  encryptedData : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => true
  post := fun i o => o.encryptedData.length = i.customerData.length ∧
                     ∀ x ∈ i.customerData, o.encryptedData.contains x

example : Spec.pre { customerData := ["data1", "data2"] } ∧
          Spec.post { customerData := ["data1", "data2"] }
                    { encryptedData := ["encrypted_data1", "encrypted_data2"] } := by
  unfold Spec; decide
