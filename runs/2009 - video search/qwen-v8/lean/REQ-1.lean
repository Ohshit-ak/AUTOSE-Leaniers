import ContractForge
open ContractForge

-- REQ-1: Torrent search will share the same search bar with the streaming search.
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  query : String
  deriving DecidableEq, Repr

structure Output where
  torrents : List String
  streamingResults : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o => o.torrents.Nodup ∧ o.streamingResults.Nodup ∧
                     o.torrents.length + o.streamingResults.length > 0

example : Spec.pre { query := "example" } ∧
          Spec.post { query := "example" }
                    { torrents := ["torrent1", "torrent2"], streamingResults := ["stream1", "stream2"] } := by
  unfold Spec; decide
