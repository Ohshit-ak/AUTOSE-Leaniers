import ContractForge
open ContractForge

-- REQ-4: Query will retrieve the no. of seed and peers, size of the file, date posted and a link to the webpage itself.

-- L0 spec

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

-- an item may be returned: it matches the query and its fields are non-empty
def Wanted (i : Input) (t : Torrent) : Bool :=
  i.query == "" ∨ t.seed ≠ 0 ∨ t.peer ≠ 0 ∨ t.size ≠ 0 ∨ t.date ≠ "" ∨ t.link ≠ ""

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (∀ t ∈ o.results, t ∈ i.torrents ∧ Wanted i t = true) ∧
    (o.results.length < 100 → ∀ t ∈ i.torrents, Wanted i t = true → t ∈ o.results) ∧
    o.results.length ≤ 100 ∧
    List.Pairwise (fun a b => a.seed ≥ b.seed ∧ a.peer ≥ b.peer ∧ a.size ≥ b.size) o.results ∧
    (o.message = "No results were found." ↔ o.results = [])

example : Spec.pre { query := "cats", torrents := [{ seed := 10, peer := 20, size := 500, date := "2023-01-01", link := "http://example.com" },
                                                    { seed := 0, peer := 0, size := 0, date := "", link := "" }] } ∧
          Spec.post { query := "cats", torrents := [{ seed := 10, peer := 20, size := 500, date := "2023-01-01", link := "http://example.com" },
                                                     { seed := 0, peer := 0, size := 0, date := "", link := "" }] }
                    { results := [{ seed := 10, peer := 20, size := 500, date := "2023-01-01", link := "http://example.com" }],
                      message := "" } := by
  unfold Spec; decide

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { results := x.torrents.filter (fun t => Wanted x t),
    message := if (x.torrents.filter (fun t => Wanted x t)).length < 100 then "" else "Results truncated." }
