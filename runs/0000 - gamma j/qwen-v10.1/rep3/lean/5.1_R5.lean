import ContractForge
open ContractForge

-- 5.1/R5: The system shall be able to search for a specified product in less than 1 second.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  products : List String
  query    : String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o => o.results.length ≤ i.products.length ∧
                     o.elapsedMicros < 1000000

example : Spec.pre { products := ["apple", "banana", "cherry"], query := "apple" } ∧
          Spec.post { products := ["apple", "banana", "cherry"], query := "apple" }
                    { results := ["apple"], elapsedMicros := 500000 } := by
  unfold Spec; decide
