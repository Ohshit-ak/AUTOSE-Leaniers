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

-- L1 architect (success=False)

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

-- Component 1: Query is not empty
def Component1Contract : Contract Input Input where
  pre  := fun i => i.query ≠ ""
  post := fun i i' => i = i'

-- Component 2: Filter torrents based on query
def Component2Contract : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (∀ it ∈ o.results, it ∈ i.torrents ∧ it == i.query) ∧
    (o.results = [] ↔ o.message = "No results were found for this search.")

-- Prove PO1: Component1Contract's assumption follows from Spec's guarantee
example : Contract.Compatible Component1Contract Spec := by
  unfold Component1Contract Spec; discharge_po

-- Prove PO2: Component2Contract refines the spec
example : Contract.Refines (Component1Contract.seq Component2Contract) Spec := by
  unfold Component1Contract Component2Contract Spec; discharge_po