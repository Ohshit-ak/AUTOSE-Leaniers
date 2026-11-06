import ContractForge
open ContractForge

-- DD-shipping-price: Cost for shipping the item to its destination; in dollars and cents

-- L0 spec

structure Input where
  value : Nat
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔ i.value ≤ 9999

example : Spec.pre { value := 500 } ∧ Spec.post { value := 500 } { valid := true } := by
  unfold Spec; decide

-- L1 architect (success=True)

structure Mid where
  value : Nat
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun _ => True
  post := fun i m => m.value = i.value ∧ m.value ≤ 9999

def ComputeContract : Contract Mid Output where
  pre  := fun m => m.value ≤ 9999
  post := fun m o => o.valid = true

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  discharge_po [ComputeContract, Spec, ValidateContract]

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  discharge_po [ComputeContract, Spec, ValidateContract]

-- L2 ValidateContract (success=False)

def ValidateContractImpl (i : Input) : Mid := { value := i.value }

theorem ValidateContractImpl_ok : ValidateContract.Satisfies ValidateContractImpl := by
  unfold Contract.Satisfies
  intro m
  simp_all
  omega

-- L2 ComputeContract (success=True)

def ComputeContractImpl (m : Mid) : Output :=
  { valid := m.value ≤ 9999 }

theorem ComputeContractImpl_ok : ComputeContract.Satisfies ComputeContractImpl := by
  discharge_po [ComputeContract, ComputeContractImpl, Spec, ValidateContract]