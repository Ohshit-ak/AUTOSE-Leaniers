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
    (∀ v ∈ o.results, v ∈ i.videos ∧ v.contains i.query) ∧
    o.results.length ≤ 100

example : Spec.pre { query := "cats", videos := ["cats and dogs", "kittens", "wild cats"] } ∧
          Spec.post { query := "cats", videos := ["cats and dogs", "kittens", "wild cats"] }
                    { results := [], message := "No results were found for this search." } := by
  unfold Spec; decide

-- L1 architect (success=False)

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
    (∀ v ∈ o.results, v ∈ i.videos ∧ v.contains i.query) ∧
    o.results.length ≤ 100

-- Component 1: Query is not empty
def QueryNonEmptyContract : Contract Input Input where
  pre  := fun i => i.query ≠ ""
  post := fun i i' => i = i'

-- Component 2: Filter videos based on query
def FilterVideosContract : Contract Input (List String) where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (∀ v ∈ o, v ∈ i.videos ∧ v.contains i.query) ∧
    o.length ≤ 100

-- Component 3: Generate output based on filtered videos
def GenerateOutputContract : Contract (List String) Output where
  pre  := fun o => true
  post := fun o o' =>
    (o'.message = "No results were found for this search." ↔ o'.results = []) ∧
    o'.results = o

-- Prove PO1: Each component's assumption follows from its predecessor's guarantee
example : Contract.Compatible QueryNonEmptyContract FilterVideosContract := by
  unfold Contract.Compatible; discharge_po

example : Contract.Compatible FilterVideosContract GenerateOutputContract := by
  unfold Contract.Compatible; discharge_po

-- Prove PO2: The composition refines the spec
example : Contract.Refines (QueryNonEmptyContract.seq FilterVideosContract).seq GenerateOutputContract Spec := by
  unfold Contract.Refines; discharge_po