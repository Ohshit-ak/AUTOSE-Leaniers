-- 3.3.3/S1: Customers will also be able to add products into the shopping cart.
-- checked: None

structure Product where
  name : String
  price : Nat

structure ShoppingCart where
  items : List (Product × Nat)

structure Contract (α : Type) where
  pre  : α → Prop
  post : α → α → Prop

def Spec : Contract ShoppingCart ShoppingCart where
  pre s := true
  post s s' := s'.items.Pairwise (·.1 ≤ ·.1) ∧ s'.items = s.items ∨
               ∃ p q n, s.items.contains (p, q) ∧ s'.items.contains (p, q + n) ∧ n > 0

example : Spec (mk ShoppingCart []) (mk ShoppingCart []) := by
  simp

example : Spec (mk ShoppingCart [(mk Product { name := "Apple", price := 1 }, 1)]) (mk ShoppingCart [(mk Product { name := "Apple", price := 1 }, 2)]) := by
  simp
