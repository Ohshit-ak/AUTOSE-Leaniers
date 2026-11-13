import ContractForge
open ContractForge

-- REQ-3#2: There will be a tick box to allow the user to choose to include video host searching in the search.

-- L0 spec

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

example : Spec.pre { includeHost := false, query := "cats" } ∧
          Spec.post { includeHost := false, query := "cats" } { results := [] } := by
  unfold Spec; decide

example : Spec.pre { includeHost := true, query := "dogs" } ∧
          Spec.post { includeHost := true, query := "dogs" } { results := ["host1", "host2"] } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  includeHost : Bool
  query       : String
  results     : List String
  deriving DecidableEq, Repr

def FilterResultsContract : Contract Input Mid where
  pre  := fun i => i.query ≠ ""
  post := fun i m => 
    (m.results.length = 0 ↔ i.includeHost = false) ∧
    (m.results.length > 0 → i.includeHost = true)

def FormatOutputContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.results = m.results
