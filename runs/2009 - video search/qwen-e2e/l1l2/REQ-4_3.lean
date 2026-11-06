import ContractForge
open ContractForge

-- REQ-4#3: Any torrent result with 0 seeds will not be displayed.

-- L0 spec

structure Torrent where
  name   : String
  seeds  : Nat
  rating : Nat
  deriving DecidableEq, Repr

structure Input where
  torrents : List Torrent
  deriving DecidableEq, Repr

structure Output where
  results : List Torrent
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => 
    (∀ it ∈ o.results, it ∈ i.torrents ∧ it.seeds ≠ 0) ∧
    (o.results = [] ↔ i.torrents.all (fun t => t.seeds = 0))

example : Spec.pre { torrents := [{ name := "T1", seeds := 5, rating := 8 }, { name := "T2", seeds := 0, rating := 7 }] } ∧ Spec.post { torrents := [{ name := "T1", seeds := 5, rating := 8 }, { name := "T2", seeds := 0, rating := 7 }] } { results := [{ name := "T1", seeds := 5, rating := 8 }] } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Torrent where
  name   : String
  seeds  : Nat
  rating : Nat
  deriving DecidableEq, Repr

structure Input where
  torrents : List Torrent
  deriving DecidableEq, Repr

structure Output where
  results : List Torrent
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => 
    (∀ it ∈ o.results, it ∈ i.torrents ∧ it.seeds ≠ 0) ∧
    (o.results = [] ↔ i.torrents.all (fun t => t.seeds = 0))

-- Decompose the spec into two components

def FilterNonZeroSeedsContract : Contract (Input, List Torrent) (Output, List Torrent) where
  pre  := fun (i, _) => True
  post := fun (i, _) (o, _) => 
    (∀ it ∈ o.results, it ∈ i.torrents ∧ it.seeds ≠ 0) ∧
    (o.results = [] ↔ i.torrents.all (fun t => t.seeds = 0))

def CollectResultsContract : Contract (Output, List Torrent) Output where
  pre  := fun (_, torrents) => torrents = []
  post := fun (_, torrents) o => 
    o.results = torrents

-- Prove PO1: each component's assumption follows from its predecessor's guarantee

theorem PO1 : Contract.Compatible FilterNonZeroSeedsContract CollectResultsContract := by
  intros i o
  simp [FilterNonZeroSeedsContract, CollectResultsContract]
  split
  -- First part: FilterNonZeroSeedsContract.post → CollectResultsContract.pre
  simp [FilterNonZeroSeedsContract.post, CollectResultsContract.pre]
  -- Second part: CollectResultsContract.post → FilterNonZeroSeedsContract.post
  simp [CollectResultsContract.post, FilterNonZeroSeedsContract.post]

-- Prove PO2: the composition refines the spec

theorem PO2 : Contract.Refines (FilterNonZeroSeedsContract.seq CollectResultsContract) Spec := by
  intros i o
  simp [FilterNonZeroSeedsContract, CollectResultsContract, Spec]
  split
  -- First part: FilterNonZeroSeedsContract.pre → Spec.pre
  simp [FilterNonZeroSeedsContract.pre, Spec.pre]
  -- Second part: FilterNonZeroSeedsContract.post → Spec.post
  simp [FilterNonZeroSeedsContract.post, Spec.post]
  -- Third part: CollectResultsContract.pre → Spec.pre
  simp [CollectResultsContract.pre, Spec.pre]
  -- Fourth part: CollectResultsContract.post → Spec.post
  simp [CollectResultsContract.post, Spec.post]
  discharge_po