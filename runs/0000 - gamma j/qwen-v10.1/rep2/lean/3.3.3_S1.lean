import ContractForge
open ContractForge

-- 3.3.3/S1: Customers will also be able to add products into the shopping cart.
-- compiles: True · rejects_bad_example: True · checked: True

structure Product where
  id   : Nat
  name : String
  price: Nat
  deriving DecidableEq, Repr

structure Cart where
  items : List Product
  deriving DecidableEq, Repr

structure Input where
  cart : Cart
  productToAdd : Product
  deriving DecidableEq, Repr

structure Output where
  cart : Cart
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.cart.items.length = i.cart.items.length + 1 ∧
                     o.cart.items.contains i.productToAdd

example : Spec.pre { cart := { items := [] }, productToAdd := { id := 1, name := "Product1", price := 100 } } ∧
          Spec.post { cart := { items := [] }, productToAdd := { id := 1, name := "Product1", price := 100 } }
                    { cart := { items := [{ id := 1, name := "Product1", price := 100 }] } } := by
  unfold Spec; decide
