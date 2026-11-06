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
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ 0 < i.price
  post := fun i o => o.name = i.name ∧ o.price = i.price ∧ o.description = i.description

example : Spec.pre { name := "Widget", price := 50, description := "A useful widget" } ∧
          Spec.post { name := "Widget", price := 50, description := "A useful widget" } { name := "Widget", price := 50, description := "A useful widget" } := by
  unfold Spec; decide
