-- 5.3/R3: The system shall encrypt all customer data in database.
-- checked: True

structure Input where
  customerData : String
  deriving DecidableEq, Repr

structure Output where
  encryptedData : String
  accepted      : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.encryptedData ≠ i.customerData ∧ o.accepted = true

example : Spec.pre { customerData := "customer123" } ∧
          Spec.post { customerData := "customer123" }
                     { encryptedData := "encrypted123", accepted := true } := by
  unfold Spec; decide
