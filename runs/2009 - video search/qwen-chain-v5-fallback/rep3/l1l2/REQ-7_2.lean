import ContractForge
open ContractForge

-- REQ-7#2: If no results are found on a search it will display a message "No results were found for this search."

-- L0 spec

structure Input where
  query : String
  videos : List String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (o.message = "No results were found for this search." ↔ o.results = []) ∧
    (∀ r ∈ o.results, r ∈ i.videos ∧ r.contains i.query) ∧
    o.results.length ≤ 100

example : Spec.pre { query := "cats", videos := ["cats and dogs", "kittens", "cat videos"] } ∧
          Spec.post { query := "cats", videos := ["cats and dogs", "kittens", "cat videos"] }
                    { results := [], message := "No results were found for this search." } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  found : List String
  deriving DecidableEq, Repr

def FindResultsContract : Contract Input Mid where
  pre  := fun i => i.query ≠ ""
  post := fun i m => ∀ r ∈ m.found, r ∈ i.videos ∧ r.contains i.query

def FormatMessageContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.message = "No results were found for this search." ↔ o.results = []) ∧
                     o.results.length ≤ 100 ∧
                     (∀ r ∈ o.results, r ∈ m.found)

theorem po1 : Contract.Compatible FindResultsContract FormatMessageContract := by
  discharge_po1 [FindResultsContract, FormatMessageContract, Spec]

theorem po2 : Contract.Refines (FindResultsContract.seq FormatMessageContract) Spec := by
  discharge_po2 [FindResultsContract, FormatMessageContract, Spec]

-- L2 FindResultsContract (success=True)

def FindResultsContractImpl (x : Input) : Mid :=
  { found := x.videos.filter (fun r => decide (r ∈ x.videos ∧ r.contains x.query)) }

theorem FindResultsContractImpl_ok : FindResultsContract.Satisfies FindResultsContractImpl := by
  discharge_po3 [FindResultsContract, FindResultsContractImpl]

-- L2 FormatMessageContract (success=True)

def FormatMessageContractImpl (x : Mid) : Output :=
  { results := (x.found.filter (fun r => decide (r ∈ x.found))).take 100,
    message := if (x.found.filter (fun r => decide (r ∈ x.found))).isEmpty then
      "No results were found for this search."
    else
      "Results found." }

theorem FormatMessageContractImpl_ok : FormatMessageContract.Satisfies FormatMessageContractImpl := by
  discharge_po3 [FormatMessageContract, FormatMessageContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (FormatMessageContractImpl ∘ FindResultsContractImpl) :=
  Contract.system_sound po1 po2 FindResultsContractImpl_ok FormatMessageContractImpl_ok
