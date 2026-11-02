import ContractForge
open ContractForge

-- REQ-5: If no results are found on a search it will display a message "No results were found for this search."
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  query          : String
  results        : List String
  deriving DecidableEq, Repr

structure Output where
  results        : List String
  message        : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (o.message = "No results were found for this search." ↔ o.results = []) ∧
    (∀ r ∈ o.results, r ∈ i.results)

example : Spec.pre { query := "cats", results := ["cats", "dog"] } ∧
          Spec.post { query := "cats", results := ["cats", "dog"] }
                    { results := [], message := "No results were found for this search." } := by
  unfold Spec; decide
