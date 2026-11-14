import ContractForge
open ContractForge

-- REQ-3: There will be a tick box to allow the user to choose to include torrent searching in the search.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  includeTorrent : Bool
  query          : String
  items          : List String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (o.results.length = 0 ↔ i.includeTorrent = false) ∧
    (o.results.length > 0 ↔ i.includeTorrent = true)

example : Spec.pre { includeTorrent := false, query := "cats", items := [] } ∧ Spec.post { includeTorrent := false, query := "cats", items := [] } { results := [] } := by
  unfold Spec; decide
