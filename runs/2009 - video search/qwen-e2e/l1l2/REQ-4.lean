import ContractForge
open ContractForge

-- REQ-4: Query will retrieve the no. of seed and peers, size of the file, date posted and a link to the webpage itself.

-- L0 spec

structure Torrent where
  seed  : Nat
  peers : Nat
  size  : Nat
  date  : String
  link  : String
  deriving DecidableEq, Repr

structure Input where
  query : String
  torrents : List Torrent
  deriving DecidableEq, Repr

structure Output where
  results : List Torrent
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (∀ it ∈ o.results, it ∈ i.torrents ∧
      it.seed > 0 ∧
      it.peers > 0 ∧
      0 < it.size ∧
      it.date ≠ "" ∧
      it.link ≠ "")
    ∧
    o.results.length ≤ 100 ∧
    (o.results = [] ↔ i.torrents = [])

example : Spec.pre { query := "example-torrent", torrents := [{ seed := 5, peers := 10, size := 100, date := "2023-01-01", link := "http://example.com" }] } ∧
          Spec.post { query := "example-torrent", torrents := [{ seed := 5, peers := 10, size := 100, date := "2023-01-01", link := "http://example.com" }] }
                    { results := [{ seed := 5, peers := 10, size := 100, date := "2023-01-01", link := "http://example.com" }] } := by
  unfold Spec; decide

example : Spec.pre { query := "example-torrent", torrents := [] } ∧
          Spec.post { query := "example-torrent", torrents := [] }
                    { results := [] } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Torrent where
  seed  : Nat
  peers : Nat
  size  : Nat
  date  : String
  link  : String
  deriving DecidableEq, Repr

structure Input where
  query : String
  torrents : List Torrent
  deriving DecidableEq, Repr

structure Output where
  results : List Torrent
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (∀ it ∈ o.results, it ∈ i.torrents ∧
      it.seed > 0 ∧
      it.peers > 0 ∧
      0 < it.size ∧
      it.date ≠ "" ∧
      it.link ≠ "")
    ∧
    o.results.length ≤ 100 ∧
    (o.results = [] ↔ i.torrents = [])

-- Decompose the spec into two components

def FilterTorrentsContract : Contract (Input × Nat) (Output × Nat) where
  pre  := fun (i, n) => i.query ≠ ""
  post := fun (i, n) (o, n) =>
    (∀ it ∈ o.results, it ∈ i.torrents ∧
      it.seed > 0 ∧
      it.peers > 0 ∧
      0 < it.size ∧
      it.date ≠ "" ∧
      it.link ≠ "")
    ∧
    o.results.length ≤ 100 ∧
    (o.results = [] ↔ i.torrents = [])

def LimitResultsContract : Contract (Output × Nat) Output where
  pre  := fun (o, n) => true
  post := fun (o, n) o' =>
    o'.results.length ≤ 100 ∧
    (o'.results = [] ↔ o.results = [])

-- Prove PO1: each component's assumption follows from its predecessor's guarantee

theorem FilterTorrentsCompatible : Contract.Compatible FilterTorrentsContract Spec :=
  by
    unfold FilterTorrentsContract Spec
    intros i o n
    simp [FilterTorrentsContract.pre, FilterTorrentsContract.post, Spec.pre, Spec.post]
    split
    -- Prove the first part of the postcondition
    simp [FilterTorrentsContract.post.1, Spec.post.1]
    -- Prove the second part of the postcondition
    simp [FilterTorrentsContract.post.2, Spec.post.2]
    -- Prove the third part of the postcondition
    simp [FilterTorrentsContract.post.3, Spec.post.3]

theorem LimitResultsCompatible : Contract.Compatible LimitResultsContract FilterTorrentsContract :=
  by
    unfold LimitResultsContract FilterTorrentsContract
    intros o n o'
    simp [LimitResultsContract.pre, LimitResultsContract.post, FilterTorrentsContract.post]
    split
    -- Prove the first part of the postcondition
    simp [LimitResultsContract.post.1, FilterTorrentsContract.post.1]
    -- Prove the second part of the postcondition
    simp [LimitResultsContract.post.2, FilterTorrentsContract.post.2]
    -- Prove the third part of the postcondition
    simp [LimitResultsContract.post.3, FilterTorrentsContract.post.3]

-- Prove PO2: the composition refines the spec

theorem SystemSound : Contract.Refines (FilterTorrentsContract.seq LimitResultsContract) Spec :=
  by
    unfold FilterTorrentsContract LimitResultsContract Spec
    intros i o
    simp [FilterTorrentsContract.pre, LimitResultsContract.pre, FilterTorrentsContract.post, LimitResultsContract.post, Spec.pre, Spec.post]
    split
    -- Prove the first part of the precondition
    simp [FilterTorrentsContract.pre, LimitResultsContract.pre, Spec.pre]
    -- Prove the first part of the postcondition
    simp [FilterTorrentsContract.post, LimitResultsContract.post, Spec.post]