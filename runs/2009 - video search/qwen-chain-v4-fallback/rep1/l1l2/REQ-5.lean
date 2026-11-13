import ContractForge
open ContractForge

-- REQ-5: If no results are found on a search it will display a message "No results were found for this search."

-- L0 spec

structure Input where
  query          : String
  items          : List String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (o.message = "No results were found for this search." ↔ o.results = []) ∧
    (∀ it ∈ o.results, it ∈ i.items)

example : Spec.pre { query := "cats", items := ["cats", "dogs", "birds"] } ∧
          Spec.post { query := "cats", items := ["cats", "dogs", "birds"] }
                    { results := [], message := "No results were found for this search." } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  found : List String
  deriving DecidableEq, Repr

def FindMatchesContract : Contract Input Mid where
  pre  := fun i => i.query ≠ ""
  post := fun i m => ∀ it ∈ m.found, it ∈ i.items

def ShowResultsContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.message = "No results were found for this search." ↔ o.results = []) ∧
                     (∀ it ∈ o.results, it ∈ m.found)

theorem po1 : Contract.Compatible FindMatchesContract ShowResultsContract := by
  discharge_po1 [FindMatchesContract, ShowResultsContract, Spec]

theorem po2 : Contract.Refines (FindMatchesContract.seq ShowResultsContract) Spec := by
  discharge_po2 [FindMatchesContract, ShowResultsContract, Spec]

-- L2 FindMatchesContract (success=True)

def FindMatchesContractImpl (x : Input) : Mid :=
  { found := x.items.filter (fun it => it.contains x.query) }

theorem FindMatchesContractImpl_ok : FindMatchesContract.Satisfies FindMatchesContractImpl := by
  discharge_po3 [FindMatchesContract, FindMatchesContractImpl]

-- L2 ShowResultsContract (success=True)

def ShowResultsContractImpl (x : Mid) : Output :=
  { results := x.found, message := if x.found = [] then "No results were found for this search." else "" }

theorem ShowResultsContractImpl_ok : ShowResultsContract.Satisfies ShowResultsContractImpl := by
  discharge_po3 [ShowResultsContract, ShowResultsContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (ShowResultsContractImpl ∘ FindMatchesContractImpl) :=
  Contract.system_sound po1 po2 FindMatchesContractImpl_ok ShowResultsContractImpl_ok
