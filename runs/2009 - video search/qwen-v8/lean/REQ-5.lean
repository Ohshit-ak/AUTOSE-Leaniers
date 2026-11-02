import ContractForge
open ContractForge

-- REQ-5: If no results are found on a search it will display a message "No results were found for this search."
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  query : String
  deriving DecidableEq, Repr

structure Output where
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.message = "No results were found for this search." ↔ i.query ≠ ""

example : Spec.pre { query := "example" } ∧
          Spec.post { query := "example" } { message := "No results were found for this search." } := by
  unfold Spec; decide
