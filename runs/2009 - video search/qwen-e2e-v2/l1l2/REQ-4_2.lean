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

-- L1 architect (success=True)

structure Mid where
  includeVideoLinks : Bool
  query             : String
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.query ≠ ""
  post := fun i m => m.includeVideoLinks = i.includeVideoLinks ∧ m.query = i.query

def ComputeContract : Contract Mid Output where
  pre  := fun m => m.query ≠ ""
  post := fun m o => 
    (o.results.length = 0 ↔ m.includeVideoLinks = false) ∧
    (o.results.length > 0 → m.includeVideoLinks = true)

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  discharge_po [ComputeContract, Spec, ValidateContract]

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  discharge_po [ComputeContract, Spec, ValidateContract]

-- L2 ValidateContract (success=True)

def ValidateContractImpl (i : Input) : Mid := { includeVideoLinks := i.includeVideoLinks, query := i.query }

theorem ValidateContractImpl_ok : ValidateContract.Satisfies ValidateContractImpl := by
  discharge_po [ComputeContract, Spec, ValidateContract, ValidateContractImpl]

-- L2 ComputeContract (success=True)

def ComputeContractImpl (m : Mid) : Output := { results := if m.includeVideoLinks then ["video1", "video2"] else [] }

theorem ComputeContractImpl_ok : ComputeContract.Satisfies ComputeContractImpl := by
  discharge_po [ComputeContract, ComputeContractImpl, Spec, ValidateContract]