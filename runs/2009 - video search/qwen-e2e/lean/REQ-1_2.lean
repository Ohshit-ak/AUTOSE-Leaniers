import ContractForge
open ContractForge

-- REQ-1#2: Streaming search will share the same search bar with the torrent search.
-- compiles: True · rejects_bad_example: False · checked: False

structure Input where
  query          : String
  deriving DecidableEq, Repr

structure Output where
  results        : List String
  message        : String
  deriving DecidableEq, Repr

-- Helper to check if a result is valid
def ValidResult (r : String) : Bool :=
  r ≠ ""

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => 
    (∀ r ∈ o.results, ValidResult r = true) ∧
    (o.message = "No results were found." ↔ o.results = []) ∧
    (o.results.length ≤ 100)

example : Spec.pre { query := "cats" } ∧
          Spec.post { query := "cats" }
                    { results := ["cats_video1", "cats_video2"], message := "" } := by
  unfold Spec; decide
