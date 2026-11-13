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

-- L1 architecture (mode=chain, success=False)

structure Mid where
  query          : String
  inResults      : List String
  message        : String
  deriving DecidableEq, Repr

def FilterResultsContract : Contract Input Mid where
  pre  := fun i => i.query ≠ ""
  post := fun i m => 
    (m.message = "No results were found." ↔ m.inResults = []) ∧
    (i.includeTorrent = true →
      (∀ r ∈ m.inResults, r.contains i.query) ∧
      m.inResults.length ≤ 100) ∧
    (i.includeTorrent = false →
      (∀ r ∈ m.inResults, ¬r.contains i.query) ∧
      m.inResults.length ≤ 100)

def FormatOutputContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => 
    o.results = m.inResults ∧
    o.message = m.message
