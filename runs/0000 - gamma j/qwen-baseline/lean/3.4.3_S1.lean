-- 3.4.3/S1: Customers will be able to confirm the order after checkout.
-- checked: True

structure Input where
  orderConfirmed : Bool

structure Output where
  orderStatus : String

def Spec : Contract Input Output where
  pre  := fun i => i.orderConfirmed = true
  post := fun i o => o.orderStatus = "confirmed" ↔ i.orderConfirmed = true

example : Spec.pre ⟨true⟩ ∧ Spec.post ⟨true⟩ ⟨"confirmed"⟩ := by
  simp [Spec]
