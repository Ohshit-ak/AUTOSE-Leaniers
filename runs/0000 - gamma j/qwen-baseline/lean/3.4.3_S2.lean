-- 3.4.3/S2: If the order is incorrect, the customer will be able to revise and update their order.
-- checked: False

structure Input where
  orderCorrect : Bool

structure Output where
  orderUpdated : Bool

def Spec : Contract Input Output where
  pre  := fun i => ¬i.orderCorrect
  post := fun i o => o.orderUpdated = true → i.orderCorrect

example : Spec.pre ⟨false⟩ ∧ Spec.post ⟨false⟩ ⟨true⟩ := by
  simp [Spec]
  constructor
  assumption
