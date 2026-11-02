import ContractForge
open ContractForge

-- UC-sales-person-add-product: Add Product: Add a product to the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Product where
  name   : String
  price  : Nat
  stock  : Nat
  deriving DecidableEq, Repr

structure Input where
  product : Product
  deriving DecidableEq, Repr

structure Output where
  product : Product
  pageCreated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.product.name ≠ "" ∧ 0 < i.product.price ∧ 0 ≤ i.product.stock
  post := fun i o => o.product = i.product ∧ o.pageCreated = true

example : Spec.pre { product := { name := "Laptop", price := 1000, stock := 50 } } ∧
          Spec.post { product := { name := "Laptop", price := 1000, stock := 50 } }
                     { product := { name := "Laptop", price := 1000, stock := 50 }, pageCreated := true } := by
  unfold Spec; decide
