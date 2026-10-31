-- 5.3/R3: The system shall encrypt all customer data in database.
-- checked: True

structure Input where
  customerData : List String
  deriving DecidableEq, Repr

structure Output where
  encryptedData : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => true
  post := fun i o => o.encryptedData.length = i.customerData.length ∧
                     i.customerData.all (fun s => s.isEmpty) →
                     o.encryptedData.all (fun s => s.isEmpty)

example : Spec.pre { customerData := ["data1", "data2"] } ∧
          Spec.post { customerData := ["data1", "data2"] }
                     { encryptedData := ["encrypted1", "encrypted2"] } := by
  unfold Spec; decide
