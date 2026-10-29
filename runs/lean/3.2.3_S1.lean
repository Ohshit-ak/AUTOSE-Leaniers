-- 3.2.3/S1: Products will be stored in multi-tiered categories; a category can contain sub categories or products.
-- checked: None

structure Category (α : Type) where
  name : String
  items : List α

structure Contract (α : Type) where
  pre  : List (Category α) → Prop
  post : List (Category α) → Prop

def Spec : Contract (List (Category α)) (List (Category α)) where
  pre cats := 
    ∀ c ∈ cats, 
      (c.items = [] → 
        (∀ sub ∈ c.items, 
          sub = Category.name c ∧ 
          sub.items = [])) 
      ∨ 
      (∃ sub ∈ c.items, 
        sub.name = c.name ∧ 
        (sub.items = [] ∨ 
          (∀ prod ∈ sub.items, 
            prod = Category.name c ∧ 
            prod.items = [])))
  post newCats := 
    ∀ c ∈ newCats, 
      (c.items = [] → 
        (∀ sub ∈ c.items, 
          sub = Category.name c ∧ 
          sub.items = [])) 
      ∨ 
      (∃ sub ∈ c.items, 
        sub.name = c.name ∧ 
        (sub.items = [] ∨ 
          (∀ prod ∈ sub.items, 
            prod = Category.name c ∧ 
            prod.items = [])))

example : Spec.pre [] := by
  simp

example : Spec.post [] := by
  simp
