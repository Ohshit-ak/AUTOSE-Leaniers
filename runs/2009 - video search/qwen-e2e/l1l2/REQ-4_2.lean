import ContractForge
open ContractForge

-- REQ-4#2: There will be a tick box to allow the user to choose to include video link searching in the search.

-- L0 spec

structure Input where
  includeVideoLinks : Bool
  query             : String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o => 
    (o.results.length = 0 ↔ i.includeVideoLinks = false) ∧
    (o.results.length > 0 → i.includeVideoLinks = true)

example : Spec.pre { includeVideoLinks := true, query := "cats" } ∧
          Spec.post { includeVideoLinks := true, query := "cats" }
                    { results := ["video1", "video2"] } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Input where
  includeVideoLinks : Bool
  query             : String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o => 
    (o.results.length = 0 ↔ i.includeVideoLinks = false) ∧
    (o.results.length > 0 → i.includeVideoLinks = true)

-- Component 1: Ensure the query is not empty
def QueryNonEmptyContract : Contract Input Input where
  pre  := fun i => i.query ≠ ""
  post := fun i i' => i = i'

-- Component 2: Determine if video links should be included based on the query
def IncludeVideoLinksContract : Contract Input Output where
  pre  := fun i => true
  post := fun i o => 
    (o.results.length = 0 ↔ i.includeVideoLinks = false) ∧
    (o.results.length > 0 → i.includeVideoLinks = true)

-- Prove PO1: QueryNonEmptyContract's postcondition follows from Spec's preconditions
example : Contract.Compatible (QueryNonEmptyContract.post) Spec.pre := by
  intros i hi
  unfold QueryNonEmptyContract Spec
  simp [hi]

-- Prove PO2: The composition of the two contracts refines the spec
example : Contract.Refines (QueryNonEmptyContract.seq IncludeVideoLinksContract) Spec := by
  unfold QueryNonEmptyContract IncludeVideoLinksContract Spec
  simp
  discharge_po