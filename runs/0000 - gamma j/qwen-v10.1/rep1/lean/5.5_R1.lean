import ContractForge
open ContractForge

-- 5.5/R1: The system shall perform searches via Dijkstra's shortest path algorithm.
-- compiles: False · rejects_bad_example: None · checked: False

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

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (∀ it ∈ o.results, it ∈ i.items ∧ Wanted i it = true) ∧
    (o.results.length < 100 → ∀ it ∈ i.items, Wanted i it = true → it ∈ o.results) ∧
    o.results.length ≤ 100 ∧
    List.Pairwise (fun a b => a.rating ≥ b.rating) o.results ∧
    (o.message = "No results were found." ↔ o.results = [])

-- IMPL: Dijkstra's shortest path algorithm

example : Spec.pre { query := "cats", includeArchive := false,
                     items := [{ name := "cats", source := "web", rating := 3 },
                               { name := "cats", source := "archive", rating := 5 }] } ∧
          Spec.post { query := "cats", includeArchive := false,
                      items := [{ name := "cats", source := "web", rating := 3 },
                                { name := "cats", source := "archive", rating := 5 }] }
                    { results := [{ name := "cats", source := "web", rating := 3 }], message := "" } := by
  unfold Spec; decide
