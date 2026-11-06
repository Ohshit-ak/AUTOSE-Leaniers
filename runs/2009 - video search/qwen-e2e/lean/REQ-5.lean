import ContractForge
open ContractForge

-- REQ-5: If no results are found on a search it will display a message "No results were found for this search."
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  query          : String
  torrents       : List String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (∀ it ∈ o.results, it ∈ i.torrents ∧ it == i.query) ∧
    (o.results = [] ↔ o.message = "No results were found for this search.")

example : Spec.pre { query := "example", torrents := ["example", "test", "sample"] } ∧
          Spec.post { query := "example", torrents := ["example", "test", "sample"] }
                    { results := [], message := "No results were found for this search." } := by
  unfold Spec; decide
