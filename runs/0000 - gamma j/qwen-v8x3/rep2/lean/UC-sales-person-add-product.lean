import ContractForge
open ContractForge

-- UC-sales-person-add-product: Add Product: Add a product to the system.
-- compiles: True · rejects_bad_example: True · checked: True

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
  newProductPageCreated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.newProduct.name ≠ "" ∧ 0 < i.newProduct.price
  post := fun i o => o.products = i.products ++ [i.newProduct] ∧
                     o.newProductPageCreated = true

example : Spec.pre { products := [], newProduct := { name := "Laptop", price := 1000 } } ∧
          Spec.post { products := [], newProduct := { name := "Laptop", price := 1000 } }
                    { products := [{ name := "Laptop", price := 1000 }], newProductPageCreated := true } := by
  unfold Spec; decide
