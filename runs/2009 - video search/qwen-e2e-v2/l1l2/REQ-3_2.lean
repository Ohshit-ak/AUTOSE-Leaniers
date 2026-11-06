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

-- L1 architect (success=True)

structure Mid where
  includeHost : Bool
  query       : String
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.query ≠ ""
  post := fun i m => m.includeHost = i.includeHost ∧ m.query = i.query

def ComputeContract : Contract Mid Output where
  pre  := fun m => m.query ≠ ""
  post := fun m o => 
    (o.results.length = 0 ↔ m.includeHost = false) ∧
    (o.results.length > 0 → m.includeHost = true)

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  discharge_po [ComputeContract, Spec, ValidateContract]

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  discharge_po [ComputeContract, Spec, ValidateContract]

-- L2 ValidateContract (success=True)

def ValidateContractImpl (i : Input) : Mid := 
  { includeHost := i.includeHost, query := i.query }

theorem ValidateContractImpl_ok : ValidateContract.Satisfies ValidateContractImpl := by
  discharge_po [ComputeContract, Spec, ValidateContract, ValidateContractImpl]

-- L2 ComputeContract (success=True)

def ComputeContractImpl (m : Mid) : Output :=
  { results := if m.includeHost then ["host1"] else [] }

theorem ComputeContractImpl_ok : ComputeContract.Satisfies ComputeContractImpl := by
  discharge_po [ComputeContract, ComputeContractImpl, Spec, ValidateContract]