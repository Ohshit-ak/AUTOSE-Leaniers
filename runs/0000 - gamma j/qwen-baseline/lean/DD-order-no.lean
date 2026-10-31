-- DD-order-no: Unique confirmation number of the order to the customer; 9 characters alphanumeric
-- checked: False

structure Input where
  orderNo : String

def isAlphanumeric (c : Char) : Prop :=
  c ∈ "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

def Spec : Contract Input String where
  pre  := fun i => i.orderNo.length = 9 ∧
                   i.orderNo.all isAlphanumeric
  post := fun i o => o = i.orderNo ∧ o.length = 9 ∧
                     o.all isAlphanumeric

example : Spec.pre ⟨"ABC123456"⟩ ∧ Spec.post ⟨"ABC123456"⟩ "ABC123456" := by
  simp [Spec]
