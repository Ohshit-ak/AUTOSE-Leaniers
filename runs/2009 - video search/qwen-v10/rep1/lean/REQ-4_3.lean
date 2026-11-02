import ContractForge
open ContractForge

-- REQ-4#3: Any torrent result with 0 seeds will not be displayed.
-- compiles: True · rejects_bad_example: True · checked: True

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
