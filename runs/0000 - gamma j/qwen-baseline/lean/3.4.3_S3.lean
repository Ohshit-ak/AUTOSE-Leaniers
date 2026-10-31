-- 3.4.3/S3: The customer will then receive a confirmation email with the specific order details.
-- checked: True

structure Input where
  orderDetails : String

structure Output where
  sentEmail : Bool

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.sentEmail = true ↔ i.orderDetails ≠ ""

example : Spec.pre ⟨"Sample Order Details"⟩ ∧ Spec.post ⟨"Sample Order Details"⟩ ⟨true⟩ := by
  simp [Spec]
