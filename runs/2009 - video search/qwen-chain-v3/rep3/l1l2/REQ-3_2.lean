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

-- L1 architecture (mode=chain, success=True)

structure Mid where
  includeHost : Bool
  query       : String
  results     : List String
  deriving DecidableEq, Repr

def FilterResultsContract : Contract Input Mid where
  pre  := fun i => i.query ≠ ""
  post := fun i m => 
    (m.includeHost = i.includeHost) ∧
    (m.results.length = 0 ↔ i.includeHost = false) ∧
    (m.results.length > 0 → i.includeHost = true)

def FormatOutputContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => 
    o.results = m.results ∧
    (o.results.length = 0 ↔ m.includeHost = false) ∧
    (o.results.length > 0 → m.includeHost = true)

theorem po1 : Contract.Compatible FilterResultsContract FormatOutputContract := by
  discharge_po1 [FilterResultsContract, FormatOutputContract, Spec]

theorem po2 : Contract.Refines (FilterResultsContract.seq FormatOutputContract) Spec := by
  discharge_po2 [FilterResultsContract, FormatOutputContract, Spec]

-- L2 FilterResultsContract (success=False)

def FilterResultsContractImpl (x : Input) : Mid :=
  { includeHost := x.includeHost, query := x.query, results := if x.includeHost then [] else [] }

-- L2 FormatOutputContract (success=False)

def FormatOutputContractImpl (x : Mid) : Output :=
  { results := x.results, includeHost := x.includeHost }
