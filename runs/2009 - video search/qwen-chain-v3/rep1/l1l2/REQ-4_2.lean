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

-- L1 architecture (mode=chain, success=True)

structure Mid where
  query             : String
  includeVideoLinks : Bool
  resultsLength     : Nat
  results           : List String
  deriving DecidableEq, Repr

def FindResultsContract : Contract Input Mid where
  pre  := fun i => i.query ≠ ""
  post := fun i m => m.query = i.query ∧ m.includeVideoLinks = i.includeVideoLinks ∧
                     (m.resultsLength = 0 ↔ i.includeVideoLinks = false) ∧
                     (m.resultsLength > 0 → i.includeVideoLinks = true)

def FormatResultsContract : Contract Mid Output where
  pre  := fun m => m.resultsLength = 0 ∨ m.includeVideoLinks = true
  post := fun m o => o.results.length = m.resultsLength ∧
                     (o.results.length = 0 ↔ m.resultsLength = 0)

theorem po1 : Contract.Compatible FindResultsContract FormatResultsContract := by
  discharge_po1 [FindResultsContract, FormatResultsContract, Spec]

theorem po2 : Contract.Refines (FindResultsContract.seq FormatResultsContract) Spec := by
  discharge_po2 [FindResultsContract, FormatResultsContract, Spec]

-- L2 FindResultsContract (success=False)

def FindResultsContractImpl (x : Input) : Mid :=
  { query := x.query, includeVideoLinks := x.includeVideoLinks, resultsLength := 0, results := [] }

-- L2 FormatResultsContract (success=False)

def FormatResultsContractImpl (x : Mid) : Output :=
  { results := if x.resultsLength = 0 then [] else x.results }
