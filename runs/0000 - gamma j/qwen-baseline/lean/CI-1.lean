-- CI-1: The WebOrder system shall send an e-mail confirmation to the customer that the items they ordered will be delivered to the shipping address along with tracking number.
-- checked: True

structure Input where
  customerEmail : String
  itemsOrdered : List String
  shippingAddress : String
  trackingNumber : String

structure Output where
  emailSent : Bool

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.emailSent = true ↔ i.customerEmail ≠ "" ∧ i.itemsOrdered ≠ [] ∧ i.shippingAddress ≠ "" ∧ i.trackingNumber ≠ ""

example : Spec.pre ⟨"customer@example.com", ["item1", "item2"], "123 Main St", "1234567890"⟩ ∧ Spec.post ⟨"customer@example.com", ["item1", "item2"], "123 Main St", "1234567890"⟩ ⟨true⟩ := by
  simp [Spec]
