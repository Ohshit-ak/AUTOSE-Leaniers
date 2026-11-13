import ContractForge
open ContractForge

-- 2.4.1/S1: Systems supporting OM should allow for analytical searches based upon multiple criteria.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  criteria : List String
  data     : List String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.criteria ≠ [] ∧ i.data ≠ []
  post := fun i o =>
    (∀ r ∈ o.results, r ∈ i.data ∧ i.criteria.all (fun c => c ∈ r)) ∧
    (o.message = "No results were found." ↔ o.results = [])

example : Spec.pre { criteria := ["infectious", "disease"], data := ["infectious disease A", "infectious disease B", "non-infectious condition"] } ∧
          Spec.post { criteria := ["infectious", "disease"], data := ["infectious disease A", "infectious disease B", "non-infectious condition"] }
                    { results := ["infectious disease A", "infectious disease B"], message := "" } := by
  unfold Spec; decide
