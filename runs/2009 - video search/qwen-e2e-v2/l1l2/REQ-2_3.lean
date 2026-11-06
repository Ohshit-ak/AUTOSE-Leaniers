import ContractForge
open ContractForge

-- REQ-2#3: Sending the hyperlink to the default browser will take less than 1 second.

-- L0 spec

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros < 1000000

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 950000 } := by
  unfold Spec; decide

-- L1 architect (success=True)

structure Mid where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun _ => True
  post := fun _ m => m.elapsedMicros < 1000000

def ComputeContract : Contract Mid Output where
  pre  := fun m => m.elapsedMicros < 1000000
  post := fun m o => o.elapsedMicros = m.elapsedMicros

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  discharge_po [ComputeContract, Spec, ValidateContract]

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  discharge_po [ComputeContract, Spec, ValidateContract]

-- L2 ValidateContract (success=False)

def ValidateContractImpl (m : Mid) : Input := { elapsedMicros := m.elapsedMicros }

theorem ValidateContractImpl_ok : ValidateContract.Satisfies ValidateContractImpl := by
  discharge_po [ValidateContract, ValidateContractImpl]

-- L2 ComputeContract (success=True)

def ComputeContractImpl (m : Mid) : Output := { elapsedMicros := m.elapsedMicros }

theorem ComputeContractImpl_ok : ComputeContract.Satisfies ComputeContractImpl := by
  discharge_po [ComputeContract, ComputeContractImpl, Spec, ValidateContract]