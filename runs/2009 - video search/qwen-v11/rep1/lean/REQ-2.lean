import ContractForge
open ContractForge

-- REQ-2: Database of torrent sites can be updated via the internet.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  sites : List String
  updateFailed : Bool
  deriving DecidableEq, Repr

structure Output where
  updatedSites : List String
  deriving DecidableEq, Repr

-- IMPL: The torrent sites database is updated via the internet.

def Spec : Contract Input Output where
  pre  := fun i => i.sites.length > 0 ∧ ¬i.updateFailed
  post := fun i o => o.updatedSites = i.sites ↔ ¬i.updateFailed

example : Spec.pre { sites := ["site1", "site2"], updateFailed := false } ∧
          Spec.post { sites := ["site1", "site2"], updateFailed := false } { updatedSites := ["site1", "site2"] } := by
  unfold Spec; decide
