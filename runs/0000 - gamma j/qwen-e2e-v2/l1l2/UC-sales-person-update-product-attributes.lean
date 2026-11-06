import ContractForge
open ContractForge

-- UC-sales-person-update-product-attributes: Update Product Attributes: Update Product attributes within the system.

-- L0 spec

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

-- L1 architect (success=True)

structure Mid where
  name   : String
  price  : Nat
  stock  : Nat
  rating : Nat
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.name ≠ "" ∧ 0 < i.price ∧ i.stock > 0 ∧ i.rating > 0
  post := fun i m => m.name = i.name ∧
                     m.price = i.price ∧
                     m.stock = i.stock ∧
                     m.rating = i.rating

def ComputeContract : Contract Mid Output where
  pre  := fun m => m.name ≠ "" ∧ 0 < m.price ∧ m.stock > 0 ∧ m.rating > 0
  post := fun m o => o.name = m.name ∧
                     o.price = m.price ∧
                     o.stock = m.stock ∧
                     o.rating = m.rating

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  discharge_po [ComputeContract, Spec, ValidateContract]

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  discharge_po [ComputeContract, Spec, ValidateContract]

-- L2 ValidateContract (success=True)

def ValidateContractImpl (i : Input) : Mid := { name := i.name, price := i.price, stock := i.stock, rating := i.rating }

theorem ValidateContractImpl_ok : ValidateContract.Satisfies ValidateContractImpl := by
  discharge_po [ComputeContract, Spec, ValidateContract, ValidateContractImpl]

-- L2 ComputeContract (success=True)

def ComputeContractImpl (m : Mid) : Output := { name := m.name, price := m.price, stock := m.stock, rating := m.rating }

theorem ComputeContractImpl_ok : ComputeContract.Satisfies ComputeContractImpl := by
  discharge_po [ComputeContract, ComputeContractImpl, Spec, ValidateContract]