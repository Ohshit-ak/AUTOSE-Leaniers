-- 3.3.3/S1: Customers will also be able to add products into the shopping cart.
-- checked: True

structure Product where
  name : String
  price : Nat

structure Cart where
  items : List Product

structure Input where
  product : Product
  cart : Cart

structure Output where
  cart : Cart

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.cart.items = i.cart.items ++ [i.product]

example : Spec.pre ⟨{ name := "Laptop", price := 1000 }, { items := [] }⟩ ∧ Spec.post ⟨{ name := "Laptop", price := 1000 }, { items := [] }⟩ ⟨{ items := [{ name := "Laptop", price := 1000 }] }⟩ := by
  simp [Spec]
