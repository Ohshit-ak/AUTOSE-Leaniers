import ContractForge
open ContractForge

-- 3.3.3/S1: Customers will also be able to add products into the shopping cart.
-- compiles: True · rejects_bad_example: None · checked: True

structure Product where
  id   : Nat
  code : String
  price: Nat
  deriving DecidableEq, Repr

structure ShoppingCart where
  items : List Product
  deriving DecidableEq, Repr

structure Input where
  cart   : ShoppingCart
  product: Product
  deriving DecidableEq, Repr

structure Output where
  cart   : ShoppingCart
  added  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.added = true ↔
    ∃ p ∈ i.cart.items, p.id = i.product.id ∨
    List.Perm (i.cart.items ++ [i.product]) o.cart.items

example : Spec.pre { cart := { items := [] }, product := { id := 1, code := "C1", price := 10 } } ∧ Spec.post { cart := { items := [] }, product := { id := 1, code := "C1", price := 10 } } { cart := { items := [{ id := 1, code := "C1", price := 10 }] }, added := false } := by
  unfold Spec; decide
