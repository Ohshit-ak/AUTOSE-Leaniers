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

structure Mid where
  torrent : Torrent
  deriving DecidableEq, Repr

def FilterTorrentsContract : Contract Input Mid where
  pre  := fun i => i.query ≠ ""
  post := fun i m => m.torrent ∈ i.torrents ∧
                     m.torrent.seed > 0 ∧
                     m.torrent.peers > 0 ∧
                     0 < m.torrent.size ∧
                     m.torrent.date ≠ "" ∧
                     m.torrent.link ≠ ""

def CollectResultsContract : Contract Mid Output where
  pre  := fun m => m.torrent.seed > 0 ∧
                   m.torrent.peers > 0 ∧
                   0 < m.torrent.size ∧
                   m.torrent.date ≠ "" ∧
                   m.torrent.link ≠ ""
  post := fun m o =>
    o.results.length ≤ 100 ∧
    (o.results = [] ↔ m.torrent.torrents = []) ∧
    (∀ it ∈ o.results, it ∈ m.torrent.torrents ∧
      it.seed > 0 ∧
      it.peers > 0 ∧
      0 < it.size ∧
      it.date ≠ "" ∧
      it.link ≠ "")

theorem po1 : Contract.Compatible FilterTorrentsContract CollectResultsContract := by
  unfold Contract.Compatible FilterTorrentsContract CollectResultsContract
  intro i m _ h
  exact h.2

theorem po2 : Contract.Refines (FilterTorrentsContract.seq CollectResultsContract) Spec := by
  unfold Contract.Refines Contract.seq FilterTorrentsContract CollectResultsContract Spec
  refine ⟨fun i h => h, ?_⟩
  intro i o _ ⟨m, ⟨hp, hq⟩, ho⟩
  simp only at *
  rw [ho, hp, hq]