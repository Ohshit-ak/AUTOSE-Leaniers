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

-- L1 architect (success=False)

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

-- Decompose the spec into two components: validation and transformation

def ValidationContract : Contract Input Product where
  pre  := fun i => i.name ≠ "" ∧ 0 < i.price
  post := fun i p => p.name = i.name ∧ p.price = i.price ∧ p.description = ""

def TransformationContract : Contract Product Output where
  pre  := fun p => p.name ≠ "" ∧ 0 < p.price
  post := fun p o => o.name = p.name ∧ o.price = p.price ∧ o.description = p.description

-- Prove PO1: each component's assumption follows from its predecessor's guarantee

theorem PO1_Validation : Contract.Compatible ValidationContract Spec :=
  by
    discharge_po

theorem PO1_Transformation : Contract.Compatible TransformationContract Spec :=
  by
    discharge_po

-- Prove PO2: the composition refines the spec

theorem PO2 : Contract.Refines (ValidationContract.seq TransformationContract) Spec :=
  by
    discharge_po