import ContractForge
open ContractForge

-- REQ-5#3: Sorting results should take less than 0.1 seconds.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  query          : String
  items          : List String
  includeArchive : Bool
  elapsedMicros  : Nat
  deriving DecidableEq, Repr

structure Output where
  results : List String
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o => (∀ it ∈ o.results, it ∈ i.items ∧ it.length ≤ 10) ∧
                     o.elapsedMicros < 100000

example : Spec.pre { query := "cats", includeArchive := false,
                     items := ["cats", "dogs", "birds"], elapsedMicros := 90000 } ∧
          Spec.post { query := "cats", includeArchive := false,
                      items := ["cats", "dogs", "birds"], elapsedMicros := 90000 }
                    { results := ["cats"], elapsedMicros := 90000 } := by
  unfold Spec; decide
