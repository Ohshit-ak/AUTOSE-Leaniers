import ContractForge
open ContractForge

-- REQ-5: If no results are found on a search it will display a message "No results were found for this search."

-- L0 spec

structure Input where
  query          : String
  results        : List String
  deriving DecidableEq, Repr

structure Output where
  message        : String
  results        : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (o.message = "No results were found for this search." ↔ o.results = []) ∧
    (o.results = [] → o.message = "No results were found for this search.")

example : Spec.pre { query := "cats", results := [] } ∧
          Spec.post { query := "cats", results := [] }
                    { message := "No results were found for this search.", results := [] } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  found : List String
  deriving DecidableEq, Repr

def FindMatchesContract : Contract Input Mid where
  pre  := fun i => i.query ≠ ""
  post := fun i m => ∀ r ∈ m.found, r ∈ i.results

def ShowResultsContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o =>
    (o.message = "No results were found for this search." ↔ m.found = []) ∧
    (m.found = [] → o.message = "No results were found for this search.") ∧
    o.results = m.found

theorem po1 : Contract.Compatible FindMatchesContract ShowResultsContract := by
  discharge_po1 [FindMatchesContract, ShowResultsContract, Spec]

theorem po2 : Contract.Refines (FindMatchesContract.seq ShowResultsContract) Spec := by
  discharge_po2 [FindMatchesContract, ShowResultsContract, Spec]

-- L2 FindMatchesContract (success=True)

def FindMatchesContractImpl (x : Input) : Mid :=
  { found := x.results.filter (fun r => decide (r ∈ x.results)) }

theorem FindMatchesContractImpl_ok : FindMatchesContract.Satisfies FindMatchesContractImpl := by
  discharge_po3 [FindMatchesContract, FindMatchesContractImpl]

-- L2 ShowResultsContract (success=False)

def ShowResultsContractImpl (x : Mid) : Output :=
  { message := if x.found = [] then "No results were found for this search." else "No results were found for this search.", 
    results := x.found }
