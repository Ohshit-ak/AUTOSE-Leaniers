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

-- L1 architect (success=True)

structure Mid where
  name : String
  price : Nat
  description : String
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.name ≠ "" ∧ 0 < i.price
  post := fun i m => m.name = i.name ∧ m.price = i.price ∧ m.description = i.description

def ComputeContract : Contract Mid Output where
  pre  := fun m => m.name ≠ "" ∧ 0 < m.price
  post := fun m o => o.name = m.name ∧ o.price = m.price ∧ o.description = m.description

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  discharge_po [ComputeContract, Spec, ValidateContract]

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  discharge_po [ComputeContract, Spec, ValidateContract]

-- L2 ValidateContract (success=True)

def ValidateContractImpl (i : Input) : Mid := { name := i.name, price := i.price, description := i.description }

theorem ValidateContractImpl_ok : ValidateContract.Satisfies ValidateContractImpl := by
  discharge_po [ComputeContract, Spec, ValidateContract, ValidateContractImpl]

-- L2 ComputeContract (success=True)

def ComputeContractImpl (m : Mid) : Output := { name := m.name, price := m.price, description := m.description }

theorem ComputeContractImpl_ok : ComputeContract.Satisfies ComputeContractImpl := by
  discharge_po [ComputeContract, ComputeContractImpl, Spec, ValidateContract]