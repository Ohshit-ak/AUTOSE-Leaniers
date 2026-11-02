import ContractForge
open ContractForge

-- REQ-5: If no results are found on a search it will display a message "No results were found for this search."
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  query          : String
  items          : List String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (o.message = "No results were found for this search." ↔ o.results = []) ∧
    (∀ it ∈ o.results, it ∈ i.items)

example : Spec.pre { query := "cats", items := ["cats", "dogs", "birds"] } ∧
          Spec.post { query := "cats", items := ["cats", "dogs", "birds"] }
                    { results := [], message := "No results were found for this search." } := by
  unfold Spec; decide
