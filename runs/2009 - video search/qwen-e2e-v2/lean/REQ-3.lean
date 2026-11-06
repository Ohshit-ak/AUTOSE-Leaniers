import ContractForge
open ContractForge

-- REQ-3: There will be a tick box to allow the user to choose to include torrent searching in the search.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  includeTorrent : Bool
  query          : String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o => (o.results.length = 0 ↔ i.includeTorrent = false) ∧
                     (i.includeTorrent = true → o.results.length > 0)

example : Spec.pre { includeTorrent := true, query := "cats" } ∧
          Spec.post { includeTorrent := true, query := "cats" }
                    { results := ["cats-torrent1", "cats-torrent2"] } := by
  unfold Spec; decide
