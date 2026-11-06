import ContractForge
open ContractForge

-- 5.1/R9: The system shall be able to restore 1000 records per second.

-- L0 spec

structure Input where
  deriving DecidableEq, Repr

structure Output where
  perSecond : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.perSecond ≥ 1000

example : Spec.pre {} ∧ Spec.post {} { perSecond := 1001 } := by
  unfold Spec; decide

-- L1 architect (success=True)

structure Mid where
  perSecond : Nat
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun _ => True
  post := fun _ m => m.perSecond ≥ 1000

def ComputeContract : Contract Mid Output where
  pre  := fun m => m.perSecond ≥ 1000
  post := fun m o => o.perSecond = m.perSecond

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  discharge_po [ComputeContract, Spec, ValidateContract]

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  discharge_po [ComputeContract, Spec, ValidateContract]

-- L2 ValidateContract (success=False)

def ValidateContractImpl (m : Mid) : Input := { perSecond := 1000 }

theorem ValidateContractImpl_ok : ValidateContract.Satisfies ValidateContractImpl := by
  unfold Contract.Satisfies
  intro m
  simp_all
  omega

-- L2 ComputeContract (success=True)

def ComputeContractImpl (m : Mid) : Output := { perSecond := m.perSecond }

theorem ComputeContractImpl_ok : ComputeContract.Satisfies ComputeContractImpl := by
  discharge_po [ComputeContract, ComputeContractImpl, Spec, ValidateContract]