import ContractForge
open ContractForge

-- 5.1/R5: The system shall be able to search for a specified product in less than 1 second.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  productCode : String
  products    : List String
  deriving DecidableEq, Repr

structure Output where
  found      : Bool
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.productCode ≠ ""
  post := fun i o => (o.found = true ↔ i.productCode ∈ i.products) ∧
                     o.elapsedMicros < 1000000

example : Spec.pre { productCode := "A1", products := ["A1", "B2", "C3"] } ∧
          Spec.post { productCode := "A1", products := ["A1", "B2", "C3"] }
                    { found := true, elapsedMicros := 500000 } := by
  unfold Spec; decide
