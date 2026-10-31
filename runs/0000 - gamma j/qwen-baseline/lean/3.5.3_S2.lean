-- 3.5.3/S2: Customers will be able to search for products matching their search criteria.
-- checked: False

structure SearchCriteria where
  name : String
  category : String

structure SearchResult where
  product : String
  matchesCriteria : Bool

def Spec : Contract SearchCriteria SearchResult where
  pre  := fun c => true
  post := fun c r => r.matchesCriteria = true ↔ (c.name = r.product) ∧ (c.category = r.product)

example : Spec.pre ⟨"laptop", "electronics"⟩ ∧ Spec.post ⟨"laptop", "electronics"⟩ ⟨true⟩ := by
  simp [Spec]
