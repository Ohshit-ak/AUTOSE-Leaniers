-- 5.3/R3: The system shall encrypt all customer data in database.
-- checked: True

structure Input where
  customerData : String

structure Output where
  encryptedData : String

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.encryptedData ≠ "not_encrypted" ↔ i.customerData ≠ o.encryptedData

example : Spec.pre ⟨"customer data"⟩ ∧ Spec.post ⟨"customer data"⟩ ⟨"encrypted data"⟩ := by
  simp [Spec]
