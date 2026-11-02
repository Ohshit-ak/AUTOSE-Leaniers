import ContractForge
open ContractForge

-- UC-sales-person-update-product-attributes: Update Product Attributes: Update Product attributes within the system.
-- compiles: True · rejects_bad_example: True · checked: True

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
  pre  := fun i => i.name ≠ "" ∧ 0 < i.price
  post := fun i o => o.name = i.name ∧ o.price = i.price ∧ o.attributes ≠ i.attributes

example : Spec.pre { name := "Laptop", price := 1000, attributes := "15 inch" } ∧
          Spec.post { name := "Laptop", price := 1000, attributes := "15 inch" }
                    { name := "Laptop", price := 1000, attributes := "17 inch" } := by
  unfold Spec; decide
