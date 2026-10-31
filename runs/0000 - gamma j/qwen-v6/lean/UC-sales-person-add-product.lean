import ContractForge
open ContractForge

-- UC-sales-person-add-product: Add Product: Add a product to the system.
-- compiles: True · rejects_bad_example: None · checked: True

structure Product where
  name : String
  price : Nat
  deriving DecidableEq, Repr

structure Input where
  products : List Product
  newProduct : Product
  deriving DecidableEq, Repr

structure Output where
  products : List Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.newProduct.name ≠ ""
  post := fun i o => o.products = i.products ++ [i.newProduct]

example : Spec.pre { products := [], newProduct := { name := "New Product", price := 100 } } ∧
          Spec.post { products := [], newProduct := { name := "New Product", price := 100 } }
                    { products := [{ name := "New Product", price := 100 }] } := by
  unfold Spec; decide
