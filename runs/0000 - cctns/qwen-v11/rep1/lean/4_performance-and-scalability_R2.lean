import ContractForge
open ContractForge

-- 4/performance-and-scalability/R2: The System must be able to perform a simple search within 5-8 seconds and a advanced search (multiple search criteria) within 10-15 seconds regardless of the storage capacity or number of cases in the system. In this context, performing a search means returning a result list. It does not include retrieving the records themselves.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  query          : String
  items          : List Item
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros  : Nat
  results        : List Item
  message        : String
  deriving DecidableEq, Repr

-- an item may be returned: it matches the query and is not filtered out (rating 0 is never shown)
def Wanted (i : Input) (it : Item) : Bool :=
  it.name == i.query && 0 < it.rating

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (∀ it ∈ o.results, it ∈ i.items ∧ Wanted i it = true) ∧
    (o.results.length < 100 → ∀ it ∈ i.items, Wanted i it = true → it ∈ o.results) ∧
    o.results.length ≤ 100 ∧
    List.Pairwise (fun a b => a.rating ≥ b.rating) o.results ∧
    (o.message = "No results were found." ↔ o.results = []) ∧
    o.elapsedMicros ≤ 8000000

example : Spec.pre { query := "cats", items := [{ name := "cats", rating := 3 },
                                                { name := "dogs", rating := 5 }] } ∧
          Spec.post { query := "cats", items := [{ name := "cats", rating := 3 },
                                                  { name := "dogs", rating := 5 }] }
                    { results := [{ name := "cats", rating := 3 }], message := "", elapsedMicros := 7000000 } := by
  unfold Spec; decide
