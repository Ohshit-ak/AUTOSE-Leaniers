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

-- L1 architect (success=False)

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

-- Component 1: Torrent Results
def TorrentResultsContract : Contract Input Output := 
  { pre  := fun i => i.query = ""
    post := fun i o => 
      o.torrentResults.length ≤ 100 ∧
      (o.torrentResults.length = 0 ↔ i.query = "") ∧
      (o.torrentResults.length > 0 → i.query ≠ "")
  }

-- Component 2: Streaming Results
def StreamingResultsContract : Contract Input Output := 
  { pre  := fun i => i.query ≠ ""
    post := fun i o => 
      o.streamingResults.length ≤ 100 ∧
      (o.streamingResults.length = 0 ↔ i.query ≠ "") ∧
      (o.streamingResults.length > 0 → i.query ≠ "")
  }

-- Prove PO1: Compatibility
theorem PO1_TorrentResults : Contract.Compatible TorrentResultsContract Spec := by
  intros i o hpre hpost
  simp [TorrentResultsContract.pre, TorrentResultsContract.post, Spec.post] at hpost
  split
  -- o.torrentResults.length ≤ 100
  simp [hpost.1] at hpre
  exact hpre
  -- (o.torrentResults.length = 0 ↔ i.query = "")
  simp [hpost.2] at hpre
  exact hpre
  -- (o.torrentResults.length > 0 → i.query ≠ "")
  simp [hpost.3] at hpre
  exact hpre

theorem PO1_StreamingResults : Contract.Compatible StreamingResultsContract Spec := by
  intros i o hpre hpost
  simp [StreamingResultsContract.pre, StreamingResultsContract.post, Spec.post] at hpost
  split
  -- o.streamingResults.length ≤ 100
  simp [hpost.1] at hpre
  exact hpre
  -- (o.streamingResults.length = 0 ↔ i.query ≠ "")
  simp [hpost.2] at hpre
  exact hpre
  -- (o.streamingResults.length > 0 → i.query ≠ "")
  simp [hpost.3] at hpre
  exact hpre

-- Prove PO2: Refinement
theorem PO2_TorrentResults : Contract.Refines (TorrentResultsContract.seq StreamingResultsContract) Spec := by
  intros i o hpre hpost
  simp [TorrentResultsContract.pre, StreamingResultsContract.pre] at hpre
  simp [TorrentResultsContract.post, StreamingResultsContract.post, Spec.post] at hpost
  split
  -- o.torrentResults.length ≤ 100
  simp [hpost.1] at hpre
  exact hpre
  -- o.streamingResults.length ≤ 100
  simp [hpost.2] at hpre
  exact hpre
  -- (o.torrentResults.length = 0 ↔ i.query = "")
  simp [hpost.3] at hpre
  exact hpre
  -- (o.streamingResults.length = 0 ↔ i.query ≠ "")
  simp [hpost.4] at hpre
  exact hpre
  -- (o.torrentResults.length > 0 → i.query ≠ "")
  simp [hpost.5] at hpre
  exact hpre
  -- (o.streamingResults.length > 0 → i.query ≠ "")
  simp [hpost.6] at hpre
  exact hpre