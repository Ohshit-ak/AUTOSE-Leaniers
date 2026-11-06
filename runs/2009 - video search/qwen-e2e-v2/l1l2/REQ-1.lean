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

structure Mid where
  torrentResults : List String
  streamingResults : List String
  deriving DecidableEq, Repr

def ValidateQueryContract : Contract Input Mid where
  pre  := fun i => i.query = ""
  post := fun i m => 
    m.torrentResults.length = 0 ∧
    m.streamingResults.length = 0

def FetchResultsContract : Contract Mid Output where
  pre  := fun m => 
    m.torrentResults.length ≤ 100 ∧
    m.streamingResults.length ≤ 100 ∧
    (m.torrentResults.length = 0 ↔ i.query = "") ∧
    (m.streamingResults.length = 0 ↔ i.query = "") ∧
    (m.torrentResults.length > 0 → i.query ≠ "") ∧
    (m.streamingResults.length > 0 → i.query ≠ "")
  post := fun m o => 
    o.torrentResults = m.torrentResults ∧
    o.streamingResults = m.streamingResults

theorem po1 : Contract.Compatible ValidateQueryContract FetchResultsContract := by
  unfold Contract.Compatible ValidateQueryContract FetchResultsContract
  intro i m _ h
  exact h.2.1

theorem po2 : Contract.Refines (ValidateQueryContract.seq FetchResultsContract) Spec := by
  unfold Contract.Refines Contract.seq ValidateQueryContract FetchResultsContract Spec
  refine ⟨fun i h => h, ?_⟩
  intro i o _ ⟨m, ⟨hp, hq, _, _, _, _⟩, ho⟩
  simp only at *
  rw [ho, hp, hq]