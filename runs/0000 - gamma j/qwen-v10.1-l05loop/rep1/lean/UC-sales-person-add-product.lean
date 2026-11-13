import ContractForge
open ContractForge

-- UC-sales-person-add-product: Add Product: Add a product to the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Product where
  name : String
  price : Nat
  description : String
  deriving DecidableEq, Repr

structure Input where
  name : String
  price : Nat
  description : String
  deriving DecidableEq, Repr

structure Output where
  name : String
  price : Nat
  description : String
  productPageCreated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ i.price > 0
  post := fun i o => o.name = i.name ∧
                     o.price = i.price ∧
                     o.description = i.description ∧
                     o.productPageCreated = true

example : Spec.pre { name := "Laptop", price := 1000, description := "A high-end laptop" } ∧
          Spec.post { name := "Laptop", price := 1000, description := "A high-end laptop" }
                    { name := "Laptop", price := 1000, description := "A high-end laptop", productPageCreated := true } := by
  unfold Spec; decide
