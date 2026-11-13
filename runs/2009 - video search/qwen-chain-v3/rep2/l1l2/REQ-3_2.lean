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
  ok          : Bool
  results     : List String
  deriving DecidableEq, Repr

def QueryCheckContract : Contract Input Mid where
  pre  := fun i => i.query ≠ ""
  post := fun i m => m.includeHost = i.includeHost ∧ m.query = i.query ∧ m.ok = (i.includeHost = false)

def ResultsCheckContract : Contract Mid Output where
  pre  := fun m => m.query ≠ ""
  post := fun m o => (o.results.length = 0 ↔ m.includeHost = false) ∧
                     (o.results.length > 0 → m.includeHost = true) ∧
                     m.ok

theorem po1 : Contract.Compatible QueryCheckContract ResultsCheckContract := by
  discharge_po1 [QueryCheckContract, ResultsCheckContract, Spec]

theorem po2 : Contract.Refines (QueryCheckContract.seq ResultsCheckContract) Spec := by
  discharge_po2 [QueryCheckContract, ResultsCheckContract, Spec]

-- L2 QueryCheckContract (success=True)

def QueryCheckContractImpl (x : Input) : Mid :=
  { includeHost := x.includeHost, query := x.query, ok := decide (x.includeHost = false), results := [] }

theorem QueryCheckContractImpl_ok : QueryCheckContract.Satisfies QueryCheckContractImpl := by
  discharge_po3 [QueryCheckContract, QueryCheckContractImpl]

-- L2 ResultsCheckContract (success=False)

def ResultsCheckContractImpl (x : Mid) : Output :=
  { results := if x.includeHost = false then [] else ["host1"] }
