-- 3.3.3/S3: The customer will also be able to add to or remove products from the shopping cart prior to checkout and order confirmation.
-- checked: False

structure Product where
  name : String
  price : Nat

structure Cart where
  items : List Product

structure Input where
  action : String
  product : Option Product
  cart : Cart

structure Output where
  cart : Cart

def Spec : Contract Input Output where
  pre  := fun i => i.action ∈ {"add", "remove"} ∧
                 (i.action = "add" → i.product ≠ none) ∧
                 (i.action = "remove" → i.product ≠ none)
  post := fun i o => o.cart.items = match i.action, i.product with
                      | "add", some p => i.cart.items ++ [p]
                      | "remove", some p => i.cart.items.filter (· ≠ p)
                      | _, _ => i.cart.items

example : Spec.pre ⟨"add", some ⟨"Apple", 100⟩, ⟨items := []⟩⟩ ∧ Spec.post ⟨"add", some ⟨"Apple", 100⟩, ⟨items := []⟩⟩ ⟨⟨items := [⟨"Apple", 100⟩]⟩⟩ := by
  simp [Spec]
