import ContractForge
open ContractForge

-- UC-sales-person-update-product-attributes: Update Product Attributes: Update Product attributes within the system.
-- compiles: True · rejects_bad_example: None · checked: True

structure Product where
  name : String
  price : Nat
  attributes : String
  deriving DecidableEq, Repr

structure Input where
  name : String
  price : Nat
  attributes : String
  deriving DecidableEq, Repr

structure Output where
  name : String
  price : Nat
  attributes : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.attributes ≠ ""
  post := fun i o => o.attributes = i.attributes

example : Spec.pre { name := "Laptop", price := 1000, attributes := "15 inch, 8GB RAM" } ∧
          Spec.post { name := "Laptop", price := 1000, attributes := "15 inch, 8GB RAM" }
                    { name := "Laptop", price := 1000, attributes := "15 inch, 8GB RAM" } := by
  unfold Spec; decide
