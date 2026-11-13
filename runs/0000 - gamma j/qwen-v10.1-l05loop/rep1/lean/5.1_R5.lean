import ContractForge
open ContractForge

-- 5.1/R5: The system shall be able to search for a specified product in less than 1 second.
-- compiles: True · rejects_bad_example: None · checked: False

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
                     o.elapsedMicros < 1000000

example : Spec.pre { product := "laptop", results := [], elapsedMicros := 0 } ∧
          Spec.post { product := "laptop", results := ["laptop A"], elapsedMicros := 999999 }
                    { results := ["laptop A"], elapsedMicros := 999999 } := by
  unfold Spec; decide
