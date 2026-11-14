import ContractForge
open ContractForge

-- REQ-7#3: Any torrent result with a rating of less than 1 will not be displayed.

-- L0 spec

structure Item where
  name   : String
  source : String
  rating : Nat
  deriving DecidableEq, Repr

structure Input where
  query          : String
  items          : List Item
  includeArchive : Bool
  deriving DecidableEq, Repr

structure Output where
  results : List Item
  message : String
  deriving DecidableEq, Repr

-- an item may be returned: it matches the query, its source is switched on,
-- and its rating is not less than 1
def Wanted (i : Input) (it : Item) : Bool :=
  it.name == i.query && (i.includeArchive || it.source != "archive") && 1 ≤ it.rating

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (∀ it ∈ o.results, it ∈ i.items ∧ Wanted i it = true) ∧
    (o.message = "No results were found." ↔ o.results = [])

example : Spec.pre { query := "cats", items := [{ name := "cats", source := "web", rating := 0 }, { name := "cats", source := "archive", rating := 1 }], includeArchive := false } ∧ Spec.post { query := "cats", items := [{ name := "cats", source := "web", rating := 0 }, { name := "cats", source := "archive", rating := 1 }], includeArchive := false } { results := [], message := "No results were found." } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  found : List Item
  deriving DecidableEq, Repr

def FindMatchesContract : Contract Input Mid where
  pre  := fun i => i.query ≠ ""
  post := fun i m => ∀ it ∈ m.found, it ∈ i.items ∧ Wanted i it = true

def ShowResultsContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.results = m.found ∧
                     (o.message = "No results were found." ↔ o.results = [])

theorem po1 : Contract.Compatible FindMatchesContract ShowResultsContract := by
  discharge_po1 [FindMatchesContract, ShowResultsContract, Spec]

theorem po2 : Contract.Refines (FindMatchesContract.seq ShowResultsContract) Spec := by
  discharge_po2 [FindMatchesContract, ShowResultsContract, Spec]

-- L2 FindMatchesContract (success=True)

def FindMatchesContractImpl (x : Input) : Mid :=
  { found := x.items.filter (fun it => decide (it ∈ x.items ∧ Wanted x it = true)) }

theorem FindMatchesContractImpl_ok : FindMatchesContract.Satisfies FindMatchesContractImpl := by
  discharge_po3 [FindMatchesContract, FindMatchesContractImpl]

-- L2 ShowResultsContract (success=True)

def ShowResultsContractImpl (x : Mid) : Output :=
  { results := x.found,
    message := if x.found = [] then "No results were found." else "" }

theorem ShowResultsContractImpl_ok : ShowResultsContract.Satisfies ShowResultsContractImpl := by
  discharge_po3 [ShowResultsContract, ShowResultsContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (ShowResultsContractImpl ∘ FindMatchesContractImpl) :=
  Contract.system_sound po1 po2 FindMatchesContractImpl_ok ShowResultsContractImpl_ok
