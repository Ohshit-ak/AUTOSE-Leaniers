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

-- L1 architecture (mode=chain, success=False)

structure Mid where
  sites : List String
  deriving DecidableEq, Repr

def UpdateDatabaseContract : Contract Input Mid where
  pre  := fun i => i.sites.length > 0
  post := fun i m => m.sites.length = i.sites.length ∧
                     (∀ s ∈ i.sites, m.sites.contains s)

def ReturnSitesContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.sites.length = m.sites.length ∧
                     (∀ s ∈ m.sites, o.sites.contains s)
