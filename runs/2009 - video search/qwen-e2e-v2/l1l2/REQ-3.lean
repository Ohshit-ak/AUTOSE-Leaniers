import ContractForge
open ContractForge

-- REQ-3: There will be a tick box to allow the user to choose to include torrent searching in the search.

-- L0 spec

structure Input where
  includeTorrent : Bool
  query          : String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o => (o.results.length = 0 ↔ i.includeTorrent = false) ∧
                     (i.includeTorrent = true → o.results.length > 0)

example : Spec.pre { includeTorrent := true, query := "cats" } ∧
          Spec.post { includeTorrent := true, query := "cats" }
                    { results := ["cats-torrent1", "cats-torrent2"] } := by
  unfold Spec; decide

-- L1 architect (success=True)

structure Mid where
  includeTorrent : Bool
  query          : String
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.query ≠ ""
  post := fun i m => m.includeTorrent = i.includeTorrent ∧ m.query = i.query

def FetchResultsContract : Contract Mid Output where
  pre  := fun m => m.query ≠ ""
  post := fun m o => (o.results.length = 0 ↔ m.includeTorrent = false) ∧
                     (m.includeTorrent = true → o.results.length > 0)

theorem po1 : Contract.Compatible ValidateContract FetchResultsContract := by
  discharge_po [FetchResultsContract, Spec, ValidateContract]

theorem po2 : Contract.Refines (ValidateContract.seq FetchResultsContract) Spec := by
  discharge_po [FetchResultsContract, Spec, ValidateContract]

-- L2 ValidateContract (success=True)

def ValidateContractImpl (i : Input) : Mid := 
  { includeTorrent := i.includeTorrent, query := i.query }

theorem ValidateContractImpl_ok : ValidateContract.Satisfies ValidateContractImpl := by
  discharge_po [FetchResultsContract, Spec, ValidateContract, ValidateContractImpl]

-- L2 FetchResultsContract (success=True)

def FetchResultsContractImpl (m : Mid) : Output := 
  { results := if m.includeTorrent then ["some-torrent-result"] else [] }

theorem FetchResultsContractImpl_ok : FetchResultsContract.Satisfies FetchResultsContractImpl := by
  discharge_po [FetchResultsContract, FetchResultsContractImpl, Spec, ValidateContract]