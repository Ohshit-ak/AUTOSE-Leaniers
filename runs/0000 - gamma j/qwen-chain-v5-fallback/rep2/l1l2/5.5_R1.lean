import ContractForge
open ContractForge

-- 5.5/R1: The system shall perform searches via Dijkstra's shortest path algorithm.

-- L0 spec

structure Item where
  name   : String
  source : String
  rating : Nat
  deriving DecidableEq, Repr

structure Input where
  query          : String
  items          : List Item
  includeArchive : Bool
  deriving DecidableEq, Repr

structure Output where
  results : List Item
  message : String
  deriving DecidableEq, Repr

-- an item may be returned: it matches the query, its source is switched on,
-- and it is not filtered out (rating 0 is never shown)
def Wanted (i : Input) (it : Item) : Bool :=
  it.name == i.query && (i.includeArchive || it.source != "archive") && 0 < it.rating

-- IMPL: Dijkstra's shortest path algorithm is used to find the optimal search results
def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (∀ it ∈ o.results, it ∈ i.items ∧ Wanted i it = true) ∧
    (o.results.length < 100 → ∀ it ∈ i.items, Wanted i it = true → it ∈ o.results) ∧
    o.results.length ≤ 100 ∧
    List.Pairwise (fun a b => a.rating ≥ b.rating) o.results ∧
    (o.message = "No results were found." ↔ o.results = [])

example : Spec.pre { query := "cats", includeArchive := false,
                     items := [{ name := "cats", source := "web", rating := 3 },
                               { name := "cats", source := "archive", rating := 5 }] } ∧
          Spec.post { query := "cats", includeArchive := false,
                      items := [{ name := "cats", source := "web", rating := 3 },
                                { name := "cats", source := "archive", rating := 5 }] }
                    { results := [{ name := "cats", source := "web", rating := 3 }], message := "" } := by
  unfold Spec; decide

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { results := (x.items.filter (fun it => it ∈ x.items ∧ Wanted x it = true)).take 100,
    message := if ((x.items.filter (fun it => it ∈ x.items ∧ Wanted x it = true)).take 100).length = 0 then "No results were found." else "" }
