import ContractForge
open ContractForge

-- REQ-3#2: There will be a tick box to allow the user to choose to include video host searching in the search.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  includeHost : Bool
  query       : String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o => 
    (o.results.length = 0 ↔ i.includeHost = false) ∧
    (o.results.length > 0 → i.includeHost = true)

example : Spec.pre { includeHost := false, query := "example" } ∧
          Spec.post { includeHost := false, query := "example" }
                    { results := [] } := by
  unfold Spec; decide

example : Spec.pre { includeHost := true, query := "example" } ∧
          Spec.post { includeHost := true, query := "example" }
                    { results := ["host1", "host2"] } := by
  unfold Spec; decide
