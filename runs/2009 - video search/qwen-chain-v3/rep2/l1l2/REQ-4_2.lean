import ContractForge
open ContractForge

-- REQ-4#2: There will be a tick box to allow the user to choose to include video link searching in the search.

-- L0 spec

structure Input where
  includeVideoLinks : Bool
  query             : String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o => 
    (o.results.length = 0 ↔ i.includeVideoLinks = false) ∧
    (o.results.length > 0 → i.includeVideoLinks = true)

example : Spec.pre { includeVideoLinks := true, query := "cats" } ∧
          Spec.post { includeVideoLinks := true, query := "cats" }
                    { results := ["video1", "video2"] } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  query             : String
  resultsLength     : Nat
  includeVideoLinks : Bool
  deriving DecidableEq, Repr

def FindResultsContract : Contract Input Mid where
  pre  := fun i => i.query ≠ ""
  post := fun i m => m.query = i.query ∧ m.resultsLength = 0 ↔ i.includeVideoLinks = false

def FormatResultsContract : Contract Mid Output where
  pre  := fun m => m.resultsLength = 0 ∨ m.includeVideoLinks
  post := fun m o => o.results.length = m.resultsLength ∧ o.includeVideoLinks = m.includeVideoLinks
