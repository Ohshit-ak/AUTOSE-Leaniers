import ContractForge
open ContractForge

-- REQ-4#3: Any torrent result with 0 seeds will not be displayed.
-- compiles: True · rejects_bad_example: True · checked: True

structure Torrent where
  name    : String
  size    : Nat
  seeds   : Nat
  leeches : Nat
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
    (∀ it ∈ o.results, it.seeds ≠ 0 ∧ it ∈ i.torrents) ∧
    (o.results = [] ↔ i.torrents.all (fun t => t.seeds = 0))

example : Spec.pre { torrents := [{ name := "T1", size := 100, seeds := 5, leeches := 10 },
                                   { name := "T2", size := 200, seeds := 0, leeches := 5 }] } ∧
          Spec.post { torrents := [{ name := "T1", size := 100, seeds := 5, leeches := 10 },
                                    { name := "T2", size := 200, seeds := 0, leeches := 5 }] }
                    { results := [{ name := "T1", size := 100, seeds := 5, leeches := 10 }] } := by
  unfold Spec; decide
