import ContractForge
open ContractForge

-- REQ-1#3: Query times will take no longer than 5 seconds to any website.

-- L0 spec

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros ≤ 5000000

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 4500000 } := by
  unfold Spec; decide

-- L1 architect (success=True)

structure Mid where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun _ => True
  post := fun _ m => m.elapsedMicros ≤ 5000000

def ComputeContract : Contract Mid Output where
  pre  := fun m => m.elapsedMicros ≤ 5000000
  post := fun m o => o.elapsedMicros = m.elapsedMicros

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  discharge_po [ComputeContract, Spec, ValidateContract]

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  discharge_po [ComputeContract, Spec, ValidateContract]

-- L2 ValidateContract (success=False)

def ValidateContractImpl (m : Mid) : Input := {}

theorem ValidateContractImpl_ok : ValidateContract.Satisfies ValidateContractImpl := by
  unfold Contract.Satisfies
  intro m
  simp_all
  exact ValidateContract.post m (ValidateContractImpl m)

-- L2 ComputeContract (success=True)

def ComputeContractImpl (m : Mid) : Output := { elapsedMicros := m.elapsedMicros }

theorem ComputeContractImpl_ok : ComputeContract.Satisfies ComputeContractImpl := by
  discharge_po [ComputeContract, ComputeContractImpl, Spec, ValidateContract]