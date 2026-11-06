import ContractForge
open ContractForge

-- REQ-3#2: There will be a tick box to allow the user to choose to include video host searching in the search.

-- L0 spec

structure Input where
  includeHost : Bool
  query       : String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o => 
    (o.results.length = 0 ↔ i.includeHost = false) ∧
    (o.results.length > 0 → i.includeHost = true)

example : Spec.pre { includeHost := false, query := "example" } ∧
          Spec.post { includeHost := false, query := "example" }
                    { results := [] } := by
  unfold Spec; decide

example : Spec.pre { includeHost := true, query := "example" } ∧
          Spec.post { includeHost := true, query := "example" }
                    { results := ["host1", "host2"] } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Input where
  includeHost : Bool
  query       : String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o => 
    (o.results.length = 0 ↔ i.includeHost = false) ∧
    (o.results.length > 0 → i.includeHost = true)

-- Component 1: Handling the case where includeHost is false
def Component1Contract : Contract Input Output := 
  { pre  := fun i => i.includeHost = false,
    post := fun i o => o.results.length = 0 }

-- Component 2: Handling the case where includeHost is true
def Component2Contract : Contract Input Output := 
  { pre  := fun i => i.includeHost = true,
    post := fun i o => o.results.length > 0 }

-- Prove PO1: Component1Contract's assumption follows from Spec's guarantee
example : Contract.Compatible (Component1Contract) Spec := by
  unfold Component1Contract Spec; discharge_po

-- Prove PO1: Component2Contract's assumption follows from Spec's guarantee
example : Contract.Compatible (Component2Contract) Spec := by
  unfold Component2Contract Spec; discharge_po

-- Prove PO2: The composition of Component1Contract and Component2Contract refines Spec
example : Contract.Refines (Component1Contract.seq Component2Contract) Spec := by
  unfold Component1Contract Component2Contract Spec; discharge_po