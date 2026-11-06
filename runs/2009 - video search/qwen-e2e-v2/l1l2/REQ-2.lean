import ContractForge
open ContractForge

-- REQ-2: Database of torrent sites can be updated via the internet.

-- L0 spec

structure Input where
  sites : List String
  deriving DecidableEq, Repr

structure Output where
  sites : List String
  deriving DecidableEq, Repr

-- IMPL: Database update via the internet

def Spec : Contract Input Output where
  pre  := fun i => i.sites.length > 0
  post := fun i o => o.sites.length = i.sites.length ∧
                     (∀ s ∈ o.sites, s ∈ i.sites)

example : Spec.pre { sites := ["site1", "site2"] } ∧
          Spec.post { sites := ["site1", "site2"] } { sites := ["site1", "site2"] } := by
  unfold Spec; decide

-- L1 architect (success=True)

structure Mid where
  sites : List String
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.sites.length > 0
  post := fun i m => m.sites.length = i.sites.length ∧
                     (∀ s ∈ m.sites, s ∈ i.sites)

def ComputeContract : Contract Mid Output where
  pre  := fun m => m.sites.length > 0
  post := fun m o => o.sites.length = m.sites.length ∧
                     (∀ s ∈ o.sites, s ∈ m.sites)

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  discharge_po [ComputeContract, Spec, ValidateContract]

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  discharge_po [ComputeContract, Spec, ValidateContract]

-- L2 ValidateContract (success=True)

def ValidateContractImpl (i : Input) : Mid := { sites := i.sites }

theorem ValidateContractImpl_ok : ValidateContract.Satisfies ValidateContractImpl := by
  discharge_po [ValidateContract, ValidateContractImpl]

-- L2 ComputeContract (success=True)

def ComputeContractImpl (m : Mid) : Output := { sites := m.sites }

theorem ComputeContractImpl_ok : ComputeContract.Satisfies ComputeContractImpl := by
  discharge_po [ComputeContract, ComputeContractImpl]