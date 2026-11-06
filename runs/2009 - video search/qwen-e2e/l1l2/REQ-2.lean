import ContractForge
open ContractForge

-- REQ-2: Database of torrent sites can be updated via the internet.

-- L0 spec

structure Input where
  sites : List String
  deriving DecidableEq, Repr

structure Output where
  sites : List String
  deriving DecidableEq, Repr

-- IMPL: Database update via the internet

def Spec : Contract Input Output where
  pre  := fun i => i.sites.length > 0
  post := fun i o => o.sites.length = i.sites.length ∧
                     (∀ s ∈ o.sites, s ∈ i.sites)

example : Spec.pre { sites := ["site1", "site2"] } ∧
          Spec.post { sites := ["site1", "site2"] } { sites := ["site1", "site2"] } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Input where
  sites : List String
  deriving DecidableEq, Repr

structure Output where
  sites : List String
  deriving DecidableEq, Repr

-- IMPL: Database update via the internet

def Spec : Contract Input Output where
  pre  := fun i => i.sites.length > 0
  post := fun i o => o.sites.length = i.sites.length ∧
                     (∀ s ∈ o.sites, s ∈ i.sites)

-- Component 1: Ensure the input list is non-empty
def NonEmptyContract : Contract Input Input where
  pre  := fun i => i.sites.length > 0
  post := fun i i' => i' = i

-- Component 2: Ensure the output list matches the input list
def MatchContract : Contract Input Output where
  pre  := fun i => i.sites.length > 0
  post := fun i o => o.sites.length = i.sites.length ∧
                     (∀ s ∈ o.sites, s ∈ i.sites)

-- Prove PO1: NonEmptyContract's postcondition is compatible with Spec's precondition
example : Contract.Compatible NonEmptyContract.Spec := by
  unfold NonEmptyContract.Spec; discharge_po

-- Prove PO1: MatchContract's postcondition is compatible with Spec's postcondition
example : Contract.Compatible MatchContract.Spec := by
  unfold MatchContract.Spec; discharge_po

-- Prove PO2: The composition of the two contracts refines the spec
example : Contract.Refines (NonEmptyContract.seq MatchContract) Spec := by
  unfold NonEmptyContract.Spec MatchContract.Spec; discharge_po