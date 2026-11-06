import ContractForge
open ContractForge

-- UC-sales-person-update-product-attributes: Update Product Attributes: Update Product attributes within the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Product where
  name   : String
  price  : Nat
  stock  : Nat
  rating : Nat
  deriving DecidableEq, Repr

structure Input where
  name   : String
  price  : Nat
  stock  : Nat
  rating : Nat
  deriving DecidableEq, Repr

structure Output where
  name   : String
  price  : Nat
  stock  : Nat
  rating : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ 0 < i.price ∧ i.stock > 0 ∧ i.rating > 0
  post := fun i o => o.name = i.name ∧
                     o.price = i.price ∧
                     o.stock = i.stock ∧
                     o.rating = i.rating

example : Spec.pre { name := "Laptop", price := 1000, stock := 50, rating := 4 } ∧
          Spec.post { name := "Laptop", price := 1000, stock := 50, rating := 4 }
                    { name := "Laptop", price := 1000, stock := 50, rating := 4 } := by
  unfold Spec; decide
