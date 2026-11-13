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

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.elapsedMicros ≤ 8000000 ∧
                     (∀ it ∈ o.results, it ∈ i.items ∧ it.name == i.query) ∧
                     o.results.length ≤ 100 ∧
                     (o.message = "No results were found." ↔ o.results = [])

example : Spec.pre { query := "cats", items := [{ name := "cats", source := "web", rating := 3 }] } ∧
          Spec.post { query := "cats", items := [{ name := "cats", source := "web", rating := 3 }],
                      elapsedMicros := 7000000, results := [{ name := "cats", source := "web", rating := 3 }], message := "" } := by
  unfold Spec; decide
