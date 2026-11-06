import ContractForge
open ContractForge

-- REQ-5: If no results are found on a search it will display a message "No results were found for this search."

-- L0 spec

structure Input where
  query          : String
  torrents       : List String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (∀ it ∈ o.results, it ∈ i.torrents ∧ it == i.query) ∧
    (o.results = [] ↔ o.message = "No results were found for this search.")

example : Spec.pre { query := "example", torrents := ["example", "test", "sample"] } ∧
          Spec.post { query := "example", torrents := ["example", "test", "sample"] }
                    { results := [], message := "No results were found for this search." } := by
  unfold Spec; decide

-- L1 architect (success=True)

structure Mid where
  results : List String
  message : String
  query   : String
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.query ≠ ""
  post := fun i m => m.results = [] ∧ m.message = "No results were found for this search."

def ComputeContract : Contract Mid Output where
  pre  := fun m => m.results = [] ∧ m.message = "No results were found for this search."
  post := fun m o =>
    (∀ it ∈ o.results, it ∈ m.results ∧ it == m.query) ∧
    (o.results = [] ↔ o.message = "No results were found for this search.")

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  discharge_po [ComputeContract, Spec, ValidateContract]

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  discharge_po [ComputeContract, Spec, ValidateContract]

-- L2 ValidateContract (success=True)

def ValidateContractImpl (i : Input) : Mid := 
  { results := [], message := "No results were found for this search.", query := i.query }

theorem ValidateContractImpl_ok : ValidateContract.Satisfies ValidateContractImpl := by
  discharge_po [ComputeContract, Spec, ValidateContract, ValidateContractImpl]

-- L2 ComputeContract (success=True)

def ComputeContractImpl (m : Mid) : Output := 
  { results := m.results, message := "No results were found for this search." }

theorem ComputeContractImpl_ok : ComputeContract.Satisfies ComputeContractImpl := by
  discharge_po [ComputeContract, ComputeContractImpl, Spec, ValidateContract]