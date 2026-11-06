import ContractForge
open ContractForge

-- 1.4/S4: The minimum total inventory will be 20,000 items.

-- L0 spec

structure Input where
  items : Nat
  deriving DecidableEq, Repr

structure Output where
  items : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.items ≥ 20000
  post := fun i o => o.items = i.items

example : Spec.pre { items := 20000 } ∧ Spec.post { items := 20000 } { items := 20000 } := by
  unfold Spec; decide

-- L1 architect (success=True)

structure Mid where
  items : Nat
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.items ≥ 20000
  post := fun i m => m.items = i.items

def ComputeContract : Contract Mid Output where
  pre  := fun m => m.items ≥ 20000
  post := fun m o => o.items = m.items

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  discharge_po [ComputeContract, Spec, ValidateContract]

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  discharge_po [ComputeContract, Spec, ValidateContract]

-- L2 ValidateContract (success=True)

def ValidateContractImpl (i : Input) : Mid := { items := i.items }

theorem ValidateContractImpl_ok : ValidateContract.Satisfies ValidateContractImpl := by
  discharge_po [ComputeContract, Spec, ValidateContract, ValidateContractImpl]

-- L2 ComputeContract (success=True)

def ComputeContractImpl (m : Mid) : Output := { items := m.items }

theorem ComputeContractImpl_ok : ComputeContract.Satisfies ComputeContractImpl := by
  discharge_po [ComputeContract, ComputeContractImpl, Spec, ValidateContract]