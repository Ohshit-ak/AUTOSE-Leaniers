import ContractForge
open ContractForge

-- UC-sales-person-update-product-attributes: Update Product Attributes: Update Product attributes within the system.
-- compiles: True · rejects_bad_example: None · checked: False

structure Product where
  name   : String
  price  : Nat
  stock  : Nat
  rating : Nat
  deriving DecidableEq, Repr

structure Input where
  productId : Nat
  name      : String
  price     : Nat
  stock     : Nat
  rating    : Nat
  deriving DecidableEq, Repr

structure Output where
  productId : Nat
  name      : String
  price     : Nat
  stock     : Nat
  rating    : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.productId ≠ 0
  post := fun i o => o.productId = i.productId ∧
                     o.name = i.name ∧
                     o.price = i.price ∧
                     o.stock = i.stock ∧
                     o.rating = i.rating

example : Spec.pre { productId := 1, name := "Laptop", price := 1000, stock := 50, rating := 4 } ∧
          Spec.post { productId := 1, name := "Laptop", price := 1000, stock := 50, rating := 4 }
                    { productId := 1, name := "Laptop", price := 1000, stock := 50, rating := 4 } := by
  unfold Spec; decide
