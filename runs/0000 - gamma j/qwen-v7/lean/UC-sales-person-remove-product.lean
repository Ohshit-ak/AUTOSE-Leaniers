import ContractForge
open ContractForge

-- UC-sales-person-remove-product: Remove Product: Remove a product from the system.
-- compiles: True · rejects_bad_example: None · checked: True

structure Product where
  name : String
  price : Nat
  deriving DecidableEq, Repr

structure System where
  products : List Product
  deriving DecidableEq, Repr

structure Input where
  product : Product
  products : List Product
  deriving DecidableEq, Repr

structure Output where
  products : List Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.product ≠ Product.mk "" 0
  post := fun i o => o.products = i.products.filter (· ≠ i.product)

example : Spec.pre { product := { name := "Product1", price := 10 }, products := [{ name := "Product2", price := 20 }] } ∧
          Spec.post { product := { name := "Product1", price := 10 }, products := [{ name := "Product2", price := 20 }] }
                    { products := [{ name := "Product2", price := 20 }] } := by
  unfold Spec; decide
