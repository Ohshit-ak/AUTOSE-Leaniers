import ContractForge
open ContractForge

-- REQ-7#2: If no results are found on a search it will display a message "No results were found for this search."
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  query : String
  videos : List String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (o.message = "No results were found for this search." ↔ o.results = []) ∧
    (∀ r ∈ o.results, r ∈ i.videos ∧ r.contains i.query) ∧
    o.results.length ≤ 100

example : Spec.pre { query := "cats", videos := ["cats and dogs", "kittens", "cat videos"] } ∧
          Spec.post { query := "cats", videos := ["cats and dogs", "kittens", "cat videos"] }
                    { results := [], message := "No results were found for this search." } := by
  unfold Spec; decide
