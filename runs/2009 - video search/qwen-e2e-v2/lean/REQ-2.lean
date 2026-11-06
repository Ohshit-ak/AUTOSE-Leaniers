import ContractForge
open ContractForge

-- REQ-2: Database of torrent sites can be updated via the internet.
-- compiles: True · rejects_bad_example: True · checked: True

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
