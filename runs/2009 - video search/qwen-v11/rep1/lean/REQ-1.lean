import ContractForge
open ContractForge

-- REQ-1: Torrent search will share the same search bar with the streaming search.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  query          : String
  streaming      : Bool
  torrent        : Bool
  deriving DecidableEq, Repr

structure Output where
  results       : List String
  message       : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (o.message = "No results were found." ↔ o.results = []) ∧
    (∀ r ∈ o.results, r = i.query) ∧
    (i.streaming ∨ i.torrent) →
    (o.results.length ≤ 100) ∧
    (o.results.length > 0 ↔ o.message = "") ∧
    (o.results.length = 0 ↔ o.message = "No results were found.") ∧
    (o.results.length > 0 → o.message = "") ∧
    (i.streaming ∨ i.torrent) ↔
    (o.results.length = 0 ∧ o.message = "Torrent search requires streaming search to be enabled.")

example : Spec.pre { query := "cats", streaming := true, torrent := false } ∧ Spec.post { query := "cats", streaming := true, torrent := false } { results := ["cats"], message := "a" } := by
  unfold Spec; decide
