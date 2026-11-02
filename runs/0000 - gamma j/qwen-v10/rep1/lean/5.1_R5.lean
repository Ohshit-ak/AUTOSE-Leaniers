import ContractForge
open ContractForge

-- 5.1/R5: The system shall be able to search for a specified product in less than 1 second.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  product : String
  items   : List String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.product ≠ ""
  post := fun i o => (∀ it ∈ o.results, it ∈ i.items ∧ it.length = i.product.length) ∧
                     o.elapsedMicros < 1000000

example : Spec.pre { product := "camera", items := ["camera", "lens", "tripod"] } ∧
          Spec.post { product := "camera", items := ["camera", "lens", "tripod"] }
                    { results := ["camera"], elapsedMicros := 500000 } := by
  unfold Spec; decide
