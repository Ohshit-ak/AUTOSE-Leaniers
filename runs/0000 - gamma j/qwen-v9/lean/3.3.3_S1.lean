import ContractForge
open ContractForge

-- 3.3.3/S1: Customers will also be able to add products into the shopping cart.
-- compiles: True · rejects_bad_example: None · checked: False

structure Product where
  id   : Nat
  name : String
  price: Nat
  deriving DecidableEq, Repr

structure Input where
  cart    : List Product
  product : Product
  deriving DecidableEq, Repr

structure Output where
  cart    : List Product
  added   : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.added = true ↔
    ∃ p ∈ i.cart, p.id = i.product.id ∨
    (o.cart.length = i.cart.length + 1 ∧
     o.cart.contains i.product = true)

example : Spec.pre { cart := [], product := { id := 1, name := "Product1", price := 100 } } ∧ Spec.post { cart := [], product := { id := 1, name := "Product1", price := 100 } } { cart := [{ id := 1, name := "Product1", price := 100 }], added := false } := by
  unfold Spec; decide
