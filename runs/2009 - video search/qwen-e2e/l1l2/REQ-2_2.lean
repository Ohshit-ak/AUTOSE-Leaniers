import ContractForge
open ContractForge

-- REQ-2#2: Database of video hosting and video linking sites can be updated via the internet.

-- L0 spec

structure Input where
  sites : List String
  deriving DecidableEq, Repr

structure Output where
  updated : Bool
  deriving DecidableEq, Repr

-- IMPL: Database update via the internet

def Spec : Contract Input Output where
  pre  := fun i => i.sites.length > 0
  post := fun i o => o.updated = true

example : Spec.pre { sites := ["site1", "site2"] } ∧
          Spec.post { sites := ["site1", "site2"] } { updated := true } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Input where
  sites : List String
  deriving DecidableEq, Repr

structure Output where
  updated : Bool
  deriving DecidableEq, Repr

-- Component 1: Ensure sites list is non-empty
def NonEmptySitesContract : Contract Input Input where
  pre  := fun i => i.sites.length > 0
  post := fun i i' => i'.sites.length = i.sites.length

-- Component 2: Update the database and set updated to true
def UpdateDatabaseContract : Contract Input Output where
  pre  := fun i => i.sites.length > 0
  post := fun i o => o.updated = true

-- Prove PO1: NonEmptySitesContract's post follows from Spec's pre
example : Contract.Compatible NonEmptySitesContract.Spec := by
  unfold NonEmptySitesContract.Spec; unfold NonEmptySitesContract; unfold UpdateDatabaseContract.Spec; unfold UpdateDatabaseContract
  simp [Contract.Compatible]; discharge_po

-- Prove PO2: The composition of the two contracts refines the spec
example : Contract.Refines (NonEmptySitesContract.seq UpdateDatabaseContract) Spec := by
  unfold NonEmptySitesContract.Spec; unfold UpdateDatabaseContract.Spec; unfold NonEmptySitesContract; unfold UpdateDatabaseContract
  simp [Contract.Refines, Contract.seq]; discharge_po