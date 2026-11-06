import ContractForge
open ContractForge

-- REQ-4: Query will retrieve the no. of seed and peers, size of the file, date posted and a link to the webpage itself.
-- compiles: True · rejects_bad_example: True · checked: True

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
