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

-- L1 architect (success=False)

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

-- Component 1: Query Non-Empty
def QueryNonEmptyContract : Contract Input Input where
  pre  := fun i => i.query ≠ ""
  post := fun i i' => i' = i

-- Component 2: Include Torrent
def IncludeTorrentContract : Contract Input Output where
  pre  := fun i => i.includeTorrent = true
  post := fun i o => o.results.length > 0

-- Prove PO1: QueryNonEmptyContract's post is compatible with Spec's pre
example : Contract.Compatible (QueryNonEmptyContract.post) Spec.pre := by
  intros i h
  simp [QueryNonEmptyContract.post, Spec.pre] at h
  exact h

-- Prove PO2: IncludeTorrentContract's post refines Spec's post
example : Contract.Refines (QueryNonEmptyContract.seq IncludeTorrentContract).post Spec.post := by
  intros i o h
  simp [QueryNonEmptyContract.post, IncludeTorrentContract.post, Spec.post] at h
  split
  - simp [h.1.1]
  - simp [h.1.2, h.2]

-- Prove PO1: IncludeTorrentContract's pre is compatible with QueryNonEmptyContract's post
example : Contract.Compatible IncludeTorrentContract.pre (QueryNonEmptyContract.post) := by
  intros i h
  simp [IncludeTorrentContract.pre, QueryNonEmptyContract.post] at h
  exact h

-- Prove PO2: The composition of the contracts refines the spec
example : Contract.Refines (QueryNonEmptyContract.seq IncludeTorrentContract).pre Spec.pre := by
  intros i h
  simp [QueryNonEmptyContract.pre, IncludeTorrentContract.pre, Spec.pre] at h
  exact h

example : Spec.pre { includeTorrent := true, query := "cats" } ∧
          Spec.post { includeTorrent := true, query := "cats" }
                    { results := ["cats-torrent1", "cats-torrent2"] } := by
  unfold Spec; decide