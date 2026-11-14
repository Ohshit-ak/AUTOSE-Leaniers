import ContractForge
open ContractForge

-- 5.1/R5: The system shall be able to search for a specified product in less than 1 second.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  product : String
  results : List String
  elapsedMicros : Nat
  deriving DecidableEq, Repr

structure Output where
  results : List String
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.product ≠ ""
  post := fun i o => o.results.length ≤ 100 ∧
                     o.elapsedMicros < 1000000 ∧
                     (o.results = [] ↔ i.results = []) ∧
                     (o.elapsedMicros = 0 ↔ i.elapsedMicros = 0)

example : Spec.pre { product := "laptop", results := ["Product found"], elapsedMicros := 900000 } ∧
          Spec.post { product := "laptop", results := ["Product found"], elapsedMicros := 900000 }
                    { results := ["Product found"], elapsedMicros := 900000 } := by
  unfold Spec; decide
