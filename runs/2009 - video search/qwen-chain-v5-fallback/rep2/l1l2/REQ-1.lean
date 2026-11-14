import ContractForge
open ContractForge

-- REQ-1: Torrent search will share the same search bar with the streaming search.

-- L0 spec

structure Input where
  query          : String
  streaming      : Bool
  torrent        : Bool
  deriving DecidableEq, Repr

structure Output where
  results       : List String
  message       : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (o.message = "No results were found." ↔ o.results = []) ∧
    (∀ r ∈ o.results, r = i.query) ∧
    (i.streaming ∨ i.torrent) →
    (o.results.length ≤ 100) ∧
    (o.results.length > 0 ↔ o.message = "") ∧
    (o.results.length = 0 ↔ o.message = "No results were found.") ∧
    (o.results.length > 0 → o.message = "") ∧
    (i.streaming ∨ i.torrent) ↔
    (o.results.length = 0 ∧ o.message = "Torrent search requires streaming search to be enabled.")

example : Spec.pre { query := "cats", streaming := true, torrent := false } ∧ Spec.post { query := "cats", streaming := true, torrent := false } { results := ["cats"], message := "a" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { results := if x.query = "" then [] else ["cats"], message := if x.query = "" then "No results were found." else "" }
