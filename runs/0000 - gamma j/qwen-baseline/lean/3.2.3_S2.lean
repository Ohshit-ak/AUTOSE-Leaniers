-- 3.2.3/S2: The inventory management will allow for administrators to update the categories, the products placed in categories, and the specific product details.
-- checked: False

structure Category where
  name : String

structure Product where
  name : String
  category : Category

structure CategoryUpdate where
  name : String
  new_name : String

structure ProductUpdate where
  name : String
  new_category : Category

structure ProductDetailUpdate where
  name : String
  new_price : Nat
  new_stock : Nat

structure Input where
  category_update : Option CategoryUpdate
  product_update : Option ProductUpdate
  product_detail_update : Option ProductDetailUpdate

structure Output where
  updated : Bool

def Spec : Contract Input Output where
  pre  := fun i => 
    i.category_update = none ∨ 
    (i.category_update ≠ none ∧ 
      (i.category_update.get).name ≠ "" ∧ 
      (i.category_update.get).new_name ≠ "")
  post := fun i o => 
    o.updated = true ↔ 
    (i.category_update ≠ none ∧ 
      (i.category_update.get).name ≠ "" ∧ 
      (i.category_update.get).new_name ≠ "") ∨
    (i.product_update ≠ none ∧ 
      (i.product_update.get).name ≠ "" ∧ 
      (i.product_update.get).new_category.name ≠ "") ∨
    (i.product_detail_update ≠ none ∧ 
      (i.product_detail_update.get).name ≠ "" ∧ 
      (i.product_detail_update.get).new_price > 0 ∧ 
      (i.product_detail_update.get).new_stock > 0)

example : Spec.pre ⟨
  category_update := some { name := "Electronics", new_name := "Gadgets" },
  product_update := none,
  product_detail_update := none
⟩ ∧ Spec.post ⟨
  category_update := some { name := "Electronics", new_name := "Gadgets" },
  product_update := none,
  product_detail_update := none
⟩ ⟨true⟩ := by
  simp [Spec]
