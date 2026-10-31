-- 1.4/I3: Confirm Orders
-- checked: True

structure Order where
  customerName : String
  orderAmount  : Nat

structure Confirmation where
  success : Bool

def Spec : Contract Order Confirmation where
  pre  := fun o => o.orderAmount > 0
  post := fun o c => c.success = true ↔ o.orderAmount > 0

example : Spec.pre ⟨"John Doe", 50⟩ ∧ Spec.post ⟨"John Doe", 50⟩ ⟨true⟩ := by
  simp [Spec]
