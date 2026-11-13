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
  includeTorrent : Bool
  query          : String
  found          : List String
  deriving DecidableEq, Repr

def FindMatchesContract : Contract Input Mid where
  pre  := fun i => i.query ≠ ""
  post := fun i m => 
    (m.includeTorrent = i.includeTorrent) ∧
    (m.query = i.query) ∧
    (m.found.length ≤ 100) ∧
    (i.includeTorrent = true →
      (∀ r ∈ m.found, r.contains i.query)) ∧
    (i.includeTorrent = false →
      (∀ r ∈ m.found, ¬r.contains i.query))

def FormatResultsContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o =>
    (o.message = "No results were found." ↔ o.results = []) ∧
    (o.results.length ≤ 100) ∧
    (∀ r ∈ o.results, r ∈ m.found)

theorem po1 : Contract.Compatible FindMatchesContract FormatResultsContract := by
  discharge_po1 [FindMatchesContract, FormatResultsContract, Spec]

theorem po2 : Contract.Refines (FindMatchesContract.seq FormatResultsContract) Spec := by
  discharge_po2 [FindMatchesContract, FormatResultsContract, Spec]

-- L2 FindMatchesContract (success=True)

def FindMatchesContractImpl (x : Input) : Mid :=
  { includeTorrent := x.includeTorrent, query := x.query, found := [] }

theorem FindMatchesContractImpl_ok : FindMatchesContract.Satisfies FindMatchesContractImpl := by
  discharge_po3 [FindMatchesContract, FindMatchesContractImpl]

-- L2 FormatResultsContract (success=False)

def FormatResultsContractImpl (x : Mid) : Output :=
  { results := x.found, message := "No results were found." }
