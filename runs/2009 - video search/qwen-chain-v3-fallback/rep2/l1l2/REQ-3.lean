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
  found : List String
  deriving DecidableEq, Repr

def FindMatchesContract : Contract Input Mid where
  pre  := fun i => i.query ≠ ""
  post := fun i m => 
    (i.includeTorrent = true → (∀ r ∈ m.found, r.contains i.query) ∧ m.found.length ≤ 100) ∧
    (i.includeTorrent = false → (∀ r ∈ m.found, ¬r.contains i.query) ∧ m.found.length ≤ 100)

def ShowResultsContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o =>
    (o.message = "No results were found." ↔ o.results = []) ∧
    (o.results = m.found)

theorem po1 : Contract.Compatible FindMatchesContract ShowResultsContract := by
  discharge_po1 [FindMatchesContract, ShowResultsContract, Spec]

theorem po2 : Contract.Refines (FindMatchesContract.seq ShowResultsContract) Spec := by
  discharge_po2 [FindMatchesContract, ShowResultsContract, Spec]

-- L2 FindMatchesContract (success=True)

def FindMatchesContractImpl (x : Input) : Mid :=
  { found := if x.includeTorrent then List.filter (·.contains x.query) ["torrent1", "torrent2", "torrent3"] else List.filter (¬·.contains x.query) ["result1", "result2", "result3"] }

theorem FindMatchesContractImpl_ok : FindMatchesContract.Satisfies FindMatchesContractImpl := by
  discharge_po3 [FindMatchesContract, FindMatchesContractImpl]

-- L2 ShowResultsContract (success=True)

def ShowResultsContractImpl (x : Mid) : Output :=
  { results := x.found, message := if x.found = [] then "No results were found." else "Results found." }

theorem ShowResultsContractImpl_ok : ShowResultsContract.Satisfies ShowResultsContractImpl := by
  discharge_po3 [ShowResultsContract, ShowResultsContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (ShowResultsContractImpl ∘ FindMatchesContractImpl) :=
  Contract.system_sound po1 po2 FindMatchesContractImpl_ok ShowResultsContractImpl_ok
