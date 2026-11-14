import ContractForge
open ContractForge

-- REQ-1#2: Streaming search will share the same search bar with the torrent search.

-- L0 spec

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

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { videoResults := x.torrentResults.filter (fun v => v ∈ x.torrentResults ∧ v.contains x.query),
    message := decide (x.torrentResults.filter (fun v => v ∈ x.torrentResults ∧ v.contains x.query).is_empty) }
