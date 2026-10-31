-- CI-2: The WebOrder system shall send an e-mail to System Administrator regarding any technical queries from customers or sales people.
-- checked: True

structure Input where
  senderType : String
  query      : String

structure Output where
  emailSent : Bool

def Spec : Contract Input Output where
  pre  := fun i => i.senderType = "customer" ∨ i.senderType = "sales person"
  post := fun i o => o.emailSent = true ↔ i.senderType = "customer" ∨ i.senderType = "sales person"

example : Spec.pre ⟨"customer", "Technical query about product"⟩ ∧ Spec.post ⟨"customer", "Technical query about product"⟩ ⟨true⟩ := by
  simp [Spec]
