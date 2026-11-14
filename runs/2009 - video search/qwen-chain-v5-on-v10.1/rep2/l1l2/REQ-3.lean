import ContractForge
open ContractForge

-- REQ-3: There will be a tick box to allow the user to choose to include torrent searching in the search.

-- L0 spec

structure Input where
  includeTorrent : Bool
  query          : String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (o.message = "No results were found." ↔ o.results = []) ∧
    (i.includeTorrent = true →
      (∀ r ∈ o.results, r.contains i.query) ∧
      o.results.length ≤ 100) ∧
    (i.includeTorrent = false →
      (∀ r ∈ o.results, ¬r.contains i.query) ∧
      o.results.length ≤ 100)

example : Spec.pre { includeTorrent := false, query := "cats" } ∧ Spec.post { includeTorrent := false, query := "cats" } { results := [], message := "No results were found." } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  results : List String
  deriving DecidableEq, Repr

def ComputeResultsContract : Contract Input Mid where
  pre  := fun i => i.query ≠ ""
  post := fun i m => 
    (i.includeTorrent = true →
      (∀ r ∈ m.results, r.contains i.query) ∧
      m.results.length ≤ 100) ∧
    (i.includeTorrent = false →
      (∀ r ∈ m.results, ¬r.contains i.query) ∧
      m.results.length ≤ 100)

def FormatMessageContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => 
    (o.message = "No results were found." ↔ o.results = []) ∧
    o.results = m.results

theorem po1 : Contract.Compatible ComputeResultsContract FormatMessageContract := by
  discharge_po1 [ComputeResultsContract, FormatMessageContract, Spec]

theorem po2 : Contract.Refines (ComputeResultsContract.seq FormatMessageContract) Spec := by
  discharge_po2 [ComputeResultsContract, FormatMessageContract, Spec]

-- L2 ComputeResultsContract (success=False)

def ComputeResultsContractImpl (x : Input) : Mid :=
  { results := if x.includeTorrent then 
                List.filter (fun r => r.contains x.query) someResults
              else 
                List.filter (fun r => ¬r.contains x.query) someResults,
    results.length ≤ 100 }

-- L2 FormatMessageContract (success=True)

def FormatMessageContractImpl (x : Mid) : Output :=
  { results := x.results,
    message := if x.results = [] then "No results were found." else "" }

theorem FormatMessageContractImpl_ok : FormatMessageContract.Satisfies FormatMessageContractImpl := by
  discharge_po3 [FormatMessageContract, FormatMessageContractImpl]
