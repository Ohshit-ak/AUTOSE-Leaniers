-- 3.1.3/S3: Furthermore, Customer profiles will also include payment information, such as the ability to store credit card information, and address information.
-- checked: False

structure Input where
  profile : String
  creditCardInfo : Option String
  addressInfo : Option String

structure Output where
  success : Bool

def Spec : Contract Input Output where
  pre  := fun i => i.profile ≠ "" ∧ (i.creditCardInfo = none ∨ i.creditCardInfo.some ≠ "") ∧ (i.addressInfo = none ∨ i.addressInfo.some ≠ "")
  post := fun i o => o.success = true ↔ i.profile ≠ ""

example : Spec.pre ⟨"John Doe", some "1234567890123456", some "123 Main St"⟩ ∧ Spec.post ⟨"John Doe", some "1234567890123456", some "123 Main St"⟩ ⟨true⟩ := by
  simp [Spec]
