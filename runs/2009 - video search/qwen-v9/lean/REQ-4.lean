import ContractForge
open ContractForge

-- REQ-4: Query will retrieve the no. of seed and peers, size of the file, date posted and a link to the webpage itself.
-- compiles: True · rejects_bad_example: False · checked: False

structure Torrent where
  seed  : Nat
  peer  : Nat
  size  : Nat
  date  : String
  link  : String
  deriving DecidableEq, Repr

structure Input where
  query          : String
  torrents       : List Torrent
  deriving DecidableEq, Repr

structure Output where
  results       : List Torrent
  message       : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (∀ it ∈ o.results, it ∈ i.torrents ∧
      it.seed > 0 ∧ it.peer > 0 ∧ it.size > 0 ∧
      it.date ≠ "" ∧ it.link ≠ "") ∧
    (o.results.length < 100 →
      ∀ it ∈ i.torrents, it.seed > 0 ∧ it.peer > 0 ∧ it.size > 0 ∧
      it.date ≠ "" ∧ it.link ≠ "" → it ∈ o.results) ∧
    o.results.length ≤ 100 ∧
    o.message = "No results were found." ↔ o.results = []

example : Spec.pre { query := "example", torrents := [{ seed := 5, peer := 10, size := 100, date := "2023-01-01", link := "http://example.com" }] } ∧
          Spec.post { query := "example", torrents := [{ seed := 5, peer := 10, size := 100, date := "2023-01-01", link := "http://example.com" }] }
                    { results := [{ seed := 5, peer := 10, size := 100, date := "2023-01-01", link := "http://example.com" }], message := "" } := by
  unfold Spec; decide
