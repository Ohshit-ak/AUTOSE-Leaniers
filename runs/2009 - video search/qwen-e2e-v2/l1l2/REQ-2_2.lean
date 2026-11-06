import ContractForge
open ContractForge

-- REQ-2#2: Database of video hosting and video linking sites can be updated via the internet.

-- L0 spec

structure Input where
  sites : List String
  deriving DecidableEq, Repr

structure Output where
  updated : Bool
  deriving DecidableEq, Repr

-- IMPL: Database update via the internet

def Spec : Contract Input Output where
  pre  := fun i => i.sites.length > 0
  post := fun i o => o.updated = true

example : Spec.pre { sites := ["site1", "site2"] } ∧
          Spec.post { sites := ["site1", "site2"] } { updated := true } := by
  unfold Spec; decide

-- L1 architect (success=True)

structure Mid where
  sites : List String
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.sites.length > 0
  post := fun i m => m.sites.length = i.sites.length

def UpdateContract : Contract Mid Output where
  pre  := fun m => m.sites.length > 0
  post := fun m o => o.updated = true

theorem po1 : Contract.Compatible ValidateContract UpdateContract := by
  discharge_po [Spec, UpdateContract, ValidateContract]

theorem po2 : Contract.Refines (ValidateContract.seq UpdateContract) Spec := by
  discharge_po [Spec, UpdateContract, ValidateContract]

-- L2 ValidateContract (success=True)

def ValidateContractImpl (i : Input) : Mid := { sites := i.sites }

theorem ValidateContractImpl_ok : ValidateContract.Satisfies ValidateContractImpl := by
  discharge_po [Spec, UpdateContract, ValidateContract, ValidateContractImpl]

-- L2 UpdateContract (success=True)

def UpdateContractImpl (m : Mid) : Output := { updated := true }

theorem UpdateContractImpl_ok : UpdateContract.Satisfies UpdateContractImpl := by
  discharge_po [UpdateContract, UpdateContractImpl]