import ContractForge
open ContractForge

-- REQ-1#2: Streaming search will share the same search bar with the torrent search.
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  query : String
  deriving DecidableEq, Repr

structure Output where
  torrentResults : List String
  streamResults  : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    o.torrentResults.length = 0 ∨
    (∀ r ∈ o.torrentResults, r ∈ i.query.toList.map (fun c => c.toString)) ∧
    o.streamResults.length = 0 ∨
    (∀ r ∈ o.streamResults, r ∈ i.query.toList.map (fun c => c.toString))

example : Spec.pre { query := "example" } ∧
          Spec.post { query := "example" }
                    { torrentResults := [], streamResults := [] } := by
  unfold Spec; decide
