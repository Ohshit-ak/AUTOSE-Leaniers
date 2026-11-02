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
  pre  := fun i => i.name ≠ "" ∧ 0 < i.price
  post := fun i o => o.name = i.name ∧
                     o.price = i.price ∧
                     o.stock = i.stock ∧
                     o.products = i.products ++ [⟨i.name, i.price, i.stock⟩]

example : Spec.pre { name := "Widget", price := 100, stock := 50, products := [] } ∧
          Spec.post { name := "Widget", price := 100, stock := 50, products := [] }
                    { name := "Widget", price := 100, stock := 50, products := [{ name := "Widget", price := 100, stock := 50 }] } := by
  unfold Spec; decide
