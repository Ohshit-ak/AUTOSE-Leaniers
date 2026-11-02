import ContractForge
open ContractForge

-- UC-sales-person-add-product: Add Product: Add a product to the system.
-- compiles: False · rejects_bad_example: None · checked: False

structure Product where
  name   : String
  price  : Nat
  stock  : Nat
  deriving DecidableEq, Repr

structure Input where
  name   : String
  price  : Nat
  stock  : Nat
  products : List Product
  deriving DecidableEq, Repr

structure Output where
  name   : String
  price  : Nat
  stock  : Nat
  products : List Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ 0 < i.price ∧ 0 ≤ i.stock
  post := fun i o => o.name = i.name ∧ o.price = i.price ∧ o.stock = i.stock ∧
                     o.products.length = i.products.length + 1 ∧
                     o.products.last = { name := i.name, price := i.price, stock := i.stock }

example : Spec.pre { name := "Laptop", price := 1000, stock := 50, products := [] } ∧
          Spec.post { name := "Laptop", price := 1000, stock := 50, products := [] }
                    { name := "Laptop", price := 1000, stock := 50, products := [{ name := "Laptop", price := 1000, stock := 50 }] } := by
  unfold Spec; decide
