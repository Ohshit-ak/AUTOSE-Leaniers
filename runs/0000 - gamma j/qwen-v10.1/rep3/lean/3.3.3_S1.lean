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
  cart    : Cart
  product : Product
  deriving DecidableEq, Repr

structure Output where
  cart    : Cart
  added   : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => (o.added = true ↔ i.product ∉ i.cart.items) ∧
                     (o.added = false → o.cart = i.cart) ∧
                     o.cart.items.length = i.cart.items.length + (if o.added then 1 else 0)

example : Spec.pre { cart := { items := [] }, product := { id := 1, name := "Product1", price := 10 } } ∧
          Spec.post { cart := { items := [] }, product := { id := 1, name := "Product1", price := 10 } }
                     { added := true, cart := { items := [{ id := 1, name := "Product1", price := 10 }] } } := by
  unfold Spec; decide
