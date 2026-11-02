import ContractForge
open ContractForge

-- REQ-1: Torrent search will share the same search bar with the streaming search.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  query          : String
  deriving DecidableEq, Repr

structure Output where
  torrentResults : List String
  streamingResults : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o => 
    (∀ t ∈ o.torrentResults, t ∈ i.query) ∧
    (∀ s ∈ o.streamingResults, s ∈ i.query) ∧
    o.torrentResults.length + o.streamingResults.length ≤ 100

example : Spec.pre { query := "cats" } ∧
          Spec.post { query := "cats" }
                    { torrentResults := ["cats-torrent1", "cats-torrent2"], streamingResults := ["cats-stream1", "cats-stream2"] } := by
  unfold Spec; decide
