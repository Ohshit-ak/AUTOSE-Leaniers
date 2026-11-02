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
  deriving DecidableEq, Repr

structure Output where
  name   : String
  price  : Nat
  stock  : Nat
  created: Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ 0 < i.price ∧ 0 < i.stock
  post := fun i o => o.created = true ∧
                     o.name = i.name ∧
                     o.price = i.price ∧
                     o.stock = i.stock

example : Spec.pre { name := "Gadgets", price := 50, stock := 100 } ∧
          Spec.post { name := "Gadgets", price := 50, stock := 100 }
                    { created := true, name := "Gadgets", price := 50, stock := 100 } := by
  unfold Spec; decide
