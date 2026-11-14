import ContractForge
open ContractForge

-- REQ-3: There will be a tick box to allow the user to choose to include torrent searching in the search.

-- L0 spec

structure Input where
  includeTorrent : Bool
  query          : String
  items          : List String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (o.results.length = 0 ↔ i.includeTorrent = false) ∧
    (o.results.length > 0 ↔ i.includeTorrent = true)

example : Spec.pre { includeTorrent := false, query := "cats", items := [] } ∧ Spec.post { includeTorrent := false, query := "cats", items := [] } { results := [] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { results := if x.includeTorrent then [] else [] }
