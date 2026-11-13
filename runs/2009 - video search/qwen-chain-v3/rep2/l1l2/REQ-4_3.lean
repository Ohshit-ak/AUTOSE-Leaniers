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

-- L1 architecture (mode=chain, success=False)

structure Mid where
  selected : List Torrent
  deriving DecidableEq, Repr

def FilterSeedsContract : Contract Input Mid where
  pre  := fun i => True
  post := fun i m => ∀ it ∈ m.selected, it ∈ i.torrents ∧ it.seeds ≠ 0

def CollectResultsContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.results = [] ↔ m.selected.all (fun t => t.seeds = 0)) ∧
                     o.results = m.selected
