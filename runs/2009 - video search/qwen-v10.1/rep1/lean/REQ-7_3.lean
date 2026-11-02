import ContractForge
open ContractForge

-- REQ-7#3: Any torrent result with a rating of less than 1 will not be displayed.
-- compiles: True · rejects_bad_example: None · checked: False

structure Torrent where
  name   : String
  rating : Nat
  deriving DecidableEq, Repr

structure Input where
  results : List Torrent
  deriving DecidableEq, Repr

structure Output where
  results : List Torrent
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => ∀ it ∈ o.results, 1 ≤ it.rating

example : Spec.pre { results := [{ name := "Torrent1", rating := 2 },
                                  { name := "Torrent2", rating := 0 }] } ∧
          Spec.post { results := [{ name := "Torrent1", rating := 2 },
                                   { name := "Torrent2", rating := 0 }] }
                    { results := [{ name := "Torrent1", rating := 2 }] } := by
  unfold Spec; decide
