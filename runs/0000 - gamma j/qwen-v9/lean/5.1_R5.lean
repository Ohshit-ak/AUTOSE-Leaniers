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
  post := fun i o => (o.results = [] ↔ i.query ∉ i.items) ∧
                     (o.results ≠ [] → (∀ it ∈ o.results, it ∈ i.items ∧ it.length ≤ 10)) ∧
                     o.elapsedMicros < 1000000

example : Spec.pre { query := "laptop", items := ["laptop", "tablet", "phone"] } ∧
          Spec.post { query := "laptop", items := ["laptop", "tablet", "phone"] }
                    { results := ["laptop"], elapsedMicros := 999999 } := by
  unfold Spec; decide

example : ¬ Spec.post { query := "nonexistent", items := ["apple", "banana"] }
                    { results := ["apple"], elapsedMicros := 500000 } := by
  unfold Spec; decide
