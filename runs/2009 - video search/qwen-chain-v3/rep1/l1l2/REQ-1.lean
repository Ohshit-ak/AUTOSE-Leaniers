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

-- L1 architecture (mode=chain, success=True)

structure Mid where
  torrentResults : List String
  streamingResults : List String
  query          : String
  deriving DecidableEq, Repr

def TorrentSearchContract : Contract Input Mid where
  pre  := fun i => True
  post := fun i m => 
    m.query = i.query ∧
    m.torrentResults.length ≤ 100 ∧
    (m.torrentResults.length = 0 ↔ i.query = "") ∧
    (m.torrentResults.length > 0 → i.query ≠ "")

def StreamingSearchContract : Contract Mid Output where
  pre  := fun m => True
  post := fun m o => 
    o.torrentResults = m.torrentResults ∧
    o.streamingResults = m.streamingResults ∧
    o.torrentResults.length ≤ 100 ∧
    o.streamingResults.length ≤ 100 ∧
    (o.torrentResults.length = 0 ↔ m.query = "") ∧
    (o.streamingResults.length = 0 ↔ m.query = "") ∧
    (o.torrentResults.length > 0 → m.query ≠ "") ∧
    (o.streamingResults.length > 0 → m.query ≠ "")

theorem po1 : Contract.Compatible TorrentSearchContract StreamingSearchContract := by
  discharge_po1 [TorrentSearchContract, StreamingSearchContract, Spec]

theorem po2 : Contract.Refines (TorrentSearchContract.seq StreamingSearchContract) Spec := by
  discharge_po2 [TorrentSearchContract, StreamingSearchContract, Spec]

-- L2 TorrentSearchContract (success=False)

def TorrentSearchContractImpl (x : Input) : Mid :=
  { torrentResults := [], streamingResults := [], query := x.query }

-- L2 StreamingSearchContract (success=False)

def StreamingSearchContractImpl (x : Mid) : Output :=
  { torrentResults := x.torrentResults,
    streamingResults := x.streamingResults,
    query := x.query }
