import ContractForge
open ContractForge

-- REQ-1: Torrent search will share the same search bar with the streaming search.

-- L0 spec

structure Input where
  query          : String
  deriving DecidableEq, Repr

structure Output where
  torrentResults : List String
  streamingResults : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => 
    o.torrentResults.length ≤ 100 ∧
    o.streamingResults.length ≤ 100 ∧
    (o.torrentResults.length = 0 ↔ i.query = "") ∧
    (o.streamingResults.length = 0 ↔ i.query = "") ∧
    (o.torrentResults.length > 0 → i.query ≠ "") ∧
    (o.streamingResults.length > 0 → i.query ≠ "")

example : Spec.pre { query := "" } ∧ Spec.post { query := "" } { torrentResults := [], streamingResults := [] } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  torrentResults : List String
  streamingResults : List String
  deriving DecidableEq, Repr

def TorrentSearchContract : Contract Input Mid where
  pre  := fun i => i.query ≠ ""
  post := fun i m => m.torrentResults.length ≤ 100 ∧
                     (m.torrentResults.length = 0 ↔ i.query = "") ∧
                     (m.torrentResults.length > 0 → i.query ≠ "")

def StreamingSearchContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.torrentResults.length = m.torrentResults.length ∧
                     o.streamingResults.length = m.streamingResults.length ∧
                     (o.torrentResults.length = 0 ↔ m.torrentResults.length = 0) ∧
                     (o.streamingResults.length = 0 ↔ m.streamingResults.length = 0) ∧
                     (o.torrentResults.length > 0 → m.torrentResults.length > 0) ∧
                     (o.streamingResults.length > 0 → m.streamingResults.length > 0)
