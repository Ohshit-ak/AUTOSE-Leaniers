import ContractForge
open ContractForge

-- 5.1/R5: The system shall be able to search for a specified product in less than 1 second.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  query : String
  products : List String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ "" ∧ i.products.Nodup
  post := fun i o => (o.results.length = 0 ∨ o.results.length ≤ i.products.length) ∧
                     o.elapsedMicros < 1000000

example : Spec.pre { query := "camera", products := ["camera", "lens", "tripod"] } ∧
          Spec.post { query := "camera", products := ["camera", "lens", "tripod"] }
                    { results := [], elapsedMicros := 500000 } := by
  unfold Spec; decide
