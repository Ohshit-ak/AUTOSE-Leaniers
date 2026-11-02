import ContractForge
open ContractForge

-- REQ-1#2: Streaming search will share the same search bar with the torrent search.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  query : String
  deriving DecidableEq, Repr

structure Output where
  torrentResults : List String
  videoResults   : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o => o.torrentResults.Nodup ∧ o.videoResults.Nodup ∧
                     o.torrentResults.length + o.videoResults.length > 0 ∧
                     (o.torrentResults.length > 0 ↔ i.query ≠ "") ∧
                     (o.videoResults.length > 0 ↔ i.query ≠ "")

example : Spec.pre { query := "example" } ∧
          Spec.post { query := "example" }
                    { torrentResults := ["result1", "result2"], videoResults := ["video1"] } := by
  unfold Spec; decide
