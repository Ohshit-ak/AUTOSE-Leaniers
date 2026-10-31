-- UC-sales-person-add-product: Add Product: Add a product to the system.
-- checked: False

structure Input where
  productInfo : String

structure Output where
  productAdded : Bool

def Spec : Contract Input Output where
  pre  := fun i => i.productInfo.length ≤ 100
  post := fun i o => o.productAdded = true

example : Spec.pre ⟨"New Product"⟩ ∧ Spec.post ⟨"New Product"⟩ ⟨true⟩ := by
  simp [Spec]
