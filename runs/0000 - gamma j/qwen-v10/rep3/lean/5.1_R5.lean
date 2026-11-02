import ContractForge
open ContractForge

-- 5.1/R5: The system shall be able to search for a specified product in less than 1 second.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  query : String
  items : List String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o => (∀ it ∈ o.results, it ∈ i.items ∧ it.length ≤ 10) ∧
                     o.elapsedMicros < 1000000

example : Spec.pre { query := "camera", items := ["camera", "lens", "tripod"] } ∧
          Spec.post { query := "camera", items := ["camera", "lens", "tripod"] }
                    { results := ["camera"], elapsedMicros := 999999 } := by
  unfold Spec; decide
