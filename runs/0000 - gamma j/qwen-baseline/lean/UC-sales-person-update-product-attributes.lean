-- UC-sales-person-update-product-attributes: Update Product Attributes: Update Product attributes within the system.
-- checked: False

structure Input where
  productID : Nat
  attributes : List String

structure Output where
  updated : Bool

def Spec : Contract Input Output where
  pre  := fun i => i.attributes ≠ []
  post := fun i o => o.updated = true → (i.attributes = [] ∨ i.attributes = List.map (·.trim) (List.filter (· ≠ "") i.attributes))

example : Spec.pre ⟨123, ["attr1", "attr2"]⟩ ∧ Spec.post ⟨123, true⟩ ⟨true⟩ := by
  simp [Spec]
  constructor
  · simp
  · simp
