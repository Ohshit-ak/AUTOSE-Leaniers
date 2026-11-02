import ContractForge
open ContractForge

-- REQ-7#3: Any torrent result with a rating of less than 1 will not be displayed.
-- compiles: True · rejects_bad_example: None · checked: False

structure Item where
  name   : String
  rating : Nat
  deriving DecidableEq, Repr

structure Input where
  query          : String
  items          : List Item
  deriving DecidableEq, Repr

structure Output where
  results : List Item
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    ∀ it ∈ o.results, it ∈ i.items ∧ it.rating ≥ 1

example : Spec.pre { query := "cats", items := [{ name := "cats", rating := 3 },
                                                 { name := "dogs", rating := 0 }] } ∧
          Spec.post { query := "cats", items := [{ name := "cats", rating := 3 },
                                                  { name := "dogs", rating := 0 }] }
                    { results := [{ name := "cats", rating := 3 }] } := by
  unfold Spec; decide
