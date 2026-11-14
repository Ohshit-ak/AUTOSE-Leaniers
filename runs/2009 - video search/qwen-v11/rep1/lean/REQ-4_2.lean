import ContractForge
open ContractForge

-- REQ-4#2: There will be a tick box to allow the user to choose to include video link searching in the search.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  includeVideoLinks : Bool
  query             : String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o => (o.results.length = 0 ↔ i.includeVideoLinks = false) ∧
                     (o.results.length > 0 → i.includeVideoLinks = true)

example : Spec.pre { includeVideoLinks := false, query := "cats" } ∧
          Spec.post { includeVideoLinks := false, query := "cats" }
                    { results := [] } := by
  unfold Spec; decide

example : Spec.pre { includeVideoLinks := true, query := "dogs" } ∧
          Spec.post { includeVideoLinks := true, query := "dogs" }
                    { results := ["video1", "video2"] } := by
  unfold Spec; decide
