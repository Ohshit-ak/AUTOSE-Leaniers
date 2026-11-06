import ContractForge
open ContractForge

-- 3.3.3/S1: Customers will also be able to add products into the shopping cart.
-- compiles: True · rejects_bad_example: True · checked: True

structure Product where
  name : String
  price : Nat
  deriving DecidableEq, Repr

structure Input where
  cart : List Product
  productToAdd : Product
  deriving DecidableEq, Repr

structure Output where
  cart : List Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.cart.length = i.cart.length + 1 ∧
                     o.cart.contains i.productToAdd

example : Spec.pre { cart := [], productToAdd := { name := "Laptop", price := 1000 } } ∧
          Spec.post { cart := [], productToAdd := { name := "Laptop", price := 1000 } }
                    { cart := [{ name := "Laptop", price := 1000 }] } := by
  unfold Spec; decide
