-- 3.2.3/S1: Products will be stored in multi-tiered categories; a category can contain sub categories or products.
-- checked: False

structure Category where
  name : String
  subCategories : List Category
  products : List String

structure Input where
  category : Category

structure Output where
  isMultiTiered : Bool

def Spec : Contract Input Output where
  pre  := fun c => c.subCategories ≠ [] ∨ c.products ≠ []
  post := fun c o => o.isMultiTiered = true ↔ c.subCategories ≠ [] ∨ c.products ≠ []

example : Spec.pre ⟨Category.name "Electronics" subCategories := [] products := ["Laptop", "Phone"]⟩ ∧ Spec.post ⟨Category.name "Electronics" subCategories := [] products := ["Laptop", "Phone"]⟩ ⟨true⟩ := by
  simp [Spec]
