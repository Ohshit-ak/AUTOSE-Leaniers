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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { torrentResults := if x.query = "" then [] else [], streamingResults := if x.query = "" then [] else [] }
