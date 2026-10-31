-- 5.1/R4: The system shall be able to add product to shopping cart in less than 2ms.
-- checked: False

structure Input where
  productID : Nat

structure Output where
  accepted : Bool
  elapsedMicros : Nat

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.accepted = true ↔ 0 < i.productID ∧ o.elapsedMicros < 2000

example : Spec.pre ⟨123⟩ ∧ Spec.post ⟨123⟩ ⟨true⟩ ⟨1000⟩ := by
  simp [Spec]
