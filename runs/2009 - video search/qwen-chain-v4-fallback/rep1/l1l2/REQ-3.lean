import ContractForge
open ContractForge

-- REQ-3: There will be a tick box to allow the user to choose to include torrent searching in the search.

-- L0 spec

structure Input where
  includeTorrent : Bool
  query          : String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (o.message = "No results were found." ↔ o.results = []) ∧
    (i.includeTorrent = true →
      (∀ r ∈ o.results, r.contains i.query) ∧
      o.results.length ≤ 100) ∧
    (i.includeTorrent = false →
      (∀ r ∈ o.results, ¬r.contains i.query) ∧
      o.results.length ≤ 100)

example : Spec.pre { includeTorrent := false, query := "cats" } ∧ Spec.post { includeTorrent := false, query := "cats" } { results := [], message := "No results were found." } := by
  unfold Spec; decide

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { results := if x.includeTorrent then List.filter (fun r => r.contains x.query) ["result1", "result2", "result3"] else ["result1", "result2", "result3"], message := "No results were found." }
