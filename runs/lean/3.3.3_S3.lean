-- 3.3.3/S3: The customer will also be able to add to or remove products from the shopping cart prior to checkout and order confirmation.
-- checked: None

structure Contract (α β : Type) where
  pre  : α → Prop
  post : α → β → Prop

structure ShoppingCart where
  products : List String

def Spec : Contract ShoppingCart (List String) where
  pre s := true
  post s products' := s.products = products' ∨
                       (s.products ≠ [] ∧ List.Perm products' s.products)

example : Spec (ShoppingCart []) [] := by
  simp [Spec]

example : Spec (ShoppingCart ["Apple", "Banana"]) ["Apple", "Banana", "Orange"] := by
  simp [Spec]

example : Spec (ShoppingCart ["Apple", "Banana"]) ["Banana"] := by
  simp [Spec]
