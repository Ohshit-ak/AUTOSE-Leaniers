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

-- IMPL: The torrent sites database is updated via the internet.

def Spec : Contract Input Output where
  pre  := fun i => i.sites.length > 0
  post := fun i o => o.sites.length = i.sites.length ∧
                     (∀ s ∈ i.sites, o.sites.contains s)

example : Spec.pre { sites := ["site1", "site2"] } ∧
          Spec.post { sites := ["site1", "site2"] } { sites := ["site1", "site2"] } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  sites : List String
  ok    : Bool
  deriving DecidableEq, Repr

def DownloadSitesContract : Contract Input Mid where
  pre  := fun i => i.sites.length > 0
  post := fun i m => m.sites = i.sites ∧ m.ok = true

def ApplyUpdatesContract : Contract Mid Output where
  pre  := fun m => m.ok
  post := fun m o => o.sites.length = m.sites.length ∧
                     (∀ s ∈ m.sites, o.sites.contains s)

theorem po1 : Contract.Compatible DownloadSitesContract ApplyUpdatesContract := by
  discharge_po1 [DownloadSitesContract, ApplyUpdatesContract, Spec]

theorem po2 : Contract.Refines (DownloadSitesContract.seq ApplyUpdatesContract) Spec := by
  discharge_po2 [DownloadSitesContract, ApplyUpdatesContract, Spec]

-- L2 DownloadSitesContract (success=True)

def DownloadSitesContractImpl (x : Input) : Mid :=
  { sites := x.sites, ok := true }

theorem DownloadSitesContractImpl_ok : DownloadSitesContract.Satisfies DownloadSitesContractImpl := by
  discharge_po3 [DownloadSitesContract, DownloadSitesContractImpl]

-- L2 ApplyUpdatesContract (success=False)

def ApplyUpdatesContractImpl (x : Mid) : Output :=
  { sites := x.sites, ok := x.ok }
