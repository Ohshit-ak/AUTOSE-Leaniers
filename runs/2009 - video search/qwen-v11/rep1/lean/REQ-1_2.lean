import ContractForge
open ContractForge

-- REQ-1#2: Streaming search will share the same search bar with the torrent search.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  query          : String
  torrentResults : List String
  deriving DecidableEq, Repr

structure Output where
  videoResults  : List String
  message       : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (o.message = "No video results were found." ↔ o.videoResults = []) ∧
    (∀ v ∈ o.videoResults, v ∈ i.torrentResults ∧ v.contains i.query)

example : Spec.pre { query := "cats", torrentResults := ["cats.mp4", "dogs.mp4", "cats.webm"] } ∧ Spec.post { query := "cats", torrentResults := ["cats.mp4", "dogs.mp4", "cats.webm"] } { videoResults := [], message := "No video results were found." } := by
  unfold Spec; decide
