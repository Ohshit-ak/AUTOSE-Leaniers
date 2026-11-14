import ContractForge
open ContractForge

-- 2.2.1.1/S1: The Project Team must demonstrate mockups of UI changes to project stakeholders early in the development process.
-- compiles: False · rejects_bad_example: None · checked: False

structure Mockup where
  changes : List String
  deriving DecidableEq, Repr

structure Input where
  stakeholders : List String
  changes      : List String
  deriving DecidableEq, Repr

structure Output where
  demonstrated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.stakeholders ≠ [] ∧ i.changes ≠ []
  post := fun i o => o.demonstrated = true ↔
    (∃ s ∈ i.stakeholders, ∃ c ∈ i.changes, c ∈ s)

example : Spec.pre { stakeholders := ["Alice", "Bob"], changes := ["Change1", "Change2"] } ∧
          Spec.post { stakeholders := ["Alice", "Bob"], changes := ["Change1", "Change2"] }
                    { demonstrated := true } := by
  unfold Spec; decide
