import ContractForge
open ContractForge

-- REQ-2: Database of torrent sites can be updated via the internet.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  sites : List String
  updated : Bool
  deriving DecidableEq, Repr

structure Output where
  updated : Bool
  sites   : List String
  deriving DecidableEq, Repr

-- IMPL: The torrent sites database is updated via an internet connection.

def Spec : Contract Input Output where
  pre  := fun i => i.sites.length > 0
  post := fun i o => o.updated = true ∧ o.sites = i.sites

example : Spec.pre { sites := ["site1", "site2"], updated := true } ∧
          Spec.post { sites := ["site1", "site2"], updated := true }
                    { sites := ["site1", "site2"], updated := true } := by
  unfold Spec; decide
