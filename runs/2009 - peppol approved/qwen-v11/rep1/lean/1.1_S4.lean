import ContractForge
open ContractForge

-- 1.1/S4: When a contracting authority publishes a contract notice, it shall include the selection, qualification and nonexclusion criteria.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  criteria : List String
  deriving DecidableEq, Repr

structure Output where
  included : Bool
  notice : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.criteria ≠ []
  post := fun i o => (o.included = true ↔
    ∃ c ∈ i.criteria, c ≠ "") ∧
    (o.included = false → o.notice = "Contract Notice without selection criteria")

example : Spec.pre { criteria := ["Experience in public procurement", "Financial stability"] } ∧
          Spec.post { criteria := ["Experience in public procurement", "Financial stability"] }
                    { included := true, notice := "Contract Notice with selection criteria" } := by
  unfold Spec; decide
