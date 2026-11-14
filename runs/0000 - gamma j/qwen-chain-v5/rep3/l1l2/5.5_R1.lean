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

-- L1 architecture (mode=chain, success=True)

structure Mid where
  results : List Item
  deriving DecidableEq, Repr

def ComputeResultsContract : Contract Input Mid where
  pre  := fun i => i.query ≠ ""
  post := fun i m => (∀ it ∈ m.results, it ∈ i.items ∧ Wanted i it = true) ∧
                     (m.results.length < 100 → ∀ it ∈ i.items, Wanted i it = true → it ∈ m.results) ∧
                     m.results.length ≤ 100 ∧
                     List.Pairwise (fun a b => a.rating ≥ b.rating) m.results

def FormatMessageContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.results = m.results ∧
                     (o.message = "No results were found." ↔ o.results = [])

theorem po1 : Contract.Compatible ComputeResultsContract FormatMessageContract := by
  discharge_po1 [ComputeResultsContract, FormatMessageContract, Spec]

theorem po2 : Contract.Refines (ComputeResultsContract.seq FormatMessageContract) Spec := by
  discharge_po2 [ComputeResultsContract, FormatMessageContract, Spec]

-- L2 ComputeResultsContract (success=False)

def ComputeResultsContractImpl (x : Input) : Mid :=
  { results := (x.items.filter (fun it => Wanted x it)).take 100 }

-- L2 FormatMessageContract (success=True)

def FormatMessageContractImpl (x : Mid) : Output :=
  { results := x.results,
    message := if x.results = [] then "No results were found." else "" }

theorem FormatMessageContractImpl_ok : FormatMessageContract.Satisfies FormatMessageContractImpl := by
  discharge_po3 [FormatMessageContract, FormatMessageContractImpl]
