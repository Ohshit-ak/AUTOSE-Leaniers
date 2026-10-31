-- UC-sales-person-remove-product: Remove Product: Remove a product from the system.
-- checked: True

structure Input where
  productId : Nat
  productInfo : String

structure Output where
  success : Bool

def Spec : Contract Input Output where
  pre  := fun i => i.productId ≠ 0
  post := fun i o => o.success = true ↔ i.productId ≠ 0

example : Spec.pre ⟨1, "Product Info"⟩ ∧ Spec.post ⟨1, "Product Info"⟩ ⟨true⟩ := by
  simp [Spec]
