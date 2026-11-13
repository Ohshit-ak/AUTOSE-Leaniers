import ContractForge
open ContractForge

-- UC-sales-person-add-product: Add Product: Add a product to the system.

-- L0 spec

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

-- L1 architecture (mode=chain, success=False)

structure Mid where
  name : String
  price : Nat
  deriving DecidableEq, Repr

def NamePriceContract : Contract Input Mid where
  pre  := fun i => i.name ≠ "" ∧ 0 < i.price
  post := fun i m => m.name = i.name ∧ m.price = i.price

def FullOutputContract : Contract Mid Output where
  pre  := fun m => True
  post := fun m o => o.name = m.name ∧ o.price = m.price ∧ o.description = m.description
