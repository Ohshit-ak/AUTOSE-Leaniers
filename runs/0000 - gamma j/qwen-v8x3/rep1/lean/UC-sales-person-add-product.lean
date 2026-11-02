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
  pre  := fun i => i.newProduct.name ≠ "" ∧ i.newProduct.price ≠ 0
  post := fun i o => o.products = i.products ++ [i.newProduct] ∧
                     o.newProductPageCreated = true

example : Spec.pre { products := [{ name := "Laptop", price := 1000 }],
                     newProduct := { name := "Mouse", price := 50 } } ∧
          Spec.post { products := [{ name := "Laptop", price := 1000 }],
                      newProduct := { name := "Mouse", price := 50 } }
                    { products := [{ name := "Laptop", price := 1000 },
                                   { name := "Mouse", price := 50 }],
                      newProductPageCreated := true } := by
  unfold Spec; decide
