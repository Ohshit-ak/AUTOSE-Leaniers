import ContractForge
open ContractForge

-- 3.3.3/S1: Customers will also be able to add products into the shopping cart.
-- compiles: True · rejects_bad_example: None · checked: False

structure Product where
  id   : Nat
  name : String
  price: Nat
  deriving DecidableEq, Repr

structure Cart where
  items : List Product
  deriving DecidableEq, Repr

structure Input where
  cart   : Cart
  product: Product
  deriving DecidableEq, Repr

structure Output where
  cart   : Cart
  added  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.added = true ↔
    ∃ p ∈ i.cart.items, p.id = i.product.id ∧
    o.cart.items = (i.cart.items.cons i.product)

example : Spec.pre { cart := { items := [] }, product := { id := 1, name := "P1", price := 10 } } ∧ Spec.post { cart := { items := [] }, product := { id := 1, name := "P1", price := 10 } } { cart := { items := [{ id := 1, name := "P1", price := 10 }] }, added := false } := by
  unfold Spec; decide
