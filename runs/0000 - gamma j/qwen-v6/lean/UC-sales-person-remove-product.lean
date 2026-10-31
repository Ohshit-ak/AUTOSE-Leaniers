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
  products : List Product
  name : String
  deriving DecidableEq, Repr

structure Output where
  products : List Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ ""
  post := fun i o => o.products = i.products.filter (fun p => p.name ≠ i.name)

example : Spec.pre { products := [{ name := "Laptop", price := 1000 }],
                     name := "Laptop" } ∧
          Spec.post { products := [{ name := "Laptop", price := 1000 }],
                      name := "Laptop" }
                    { products := [] } := by
  unfold Spec; decide
