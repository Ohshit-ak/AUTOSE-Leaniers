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

structure Mid where
  query : String
  videos : List String
  results : List String
  message : String
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.query ≠ ""
  post := fun i m => m.query = i.query ∧ m.videos = i.videos ∧ m.message = "No results were found for this search." ↔ m.results = []

def ComputeContract : Contract Mid Output where
  pre  := fun m => m.query ≠ "" ∧ m.videos ≠ [] ∧ m.message = "No results were found for this search." ↔ m.results = []
  post := fun m o =>
    (o.message = "No results were found for this search." ↔ o.results = []) ∧
    (∀ v ∈ o.results, v ∈ m.videos ∧ v.contains m.query) ∧
    o.results.length ≤ 100

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  unfold Contract.Compatible ValidateContract ComputeContract
  intro i m _ h
  split
  · simp only [h.2.1, h.2.2]
  · simp only [h.1.1, h.1.2]

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  unfold Contract.Refines Contract.seq ValidateContract ComputeContract Spec
  refine ⟨fun i h => h, ?_⟩
  intro i o _ ⟨m, ⟨hp, hq, _⟩, ho⟩
  simp only at *
  rw [ho, hp, hq]