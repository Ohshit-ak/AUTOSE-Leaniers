import ContractForge
open ContractForge

-- 1.1/S4: When a contracting authority publishes a contract notice, it shall include the selection, qualification and nonexclusion criteria.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  criteria : List String
  deriving DecidableEq, Repr

structure Output where
  notice : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.criteria ≠ []
  post := fun i o => o.notice.containsAll i.criteria

example : Spec.pre { criteria := ["qualification", "selection", "nonexclusion"] } ∧
          Spec.post { criteria := ["qualification", "selection", "nonexclusion"] }
                     { notice := "This contract notice includes the selection, qualification and nonexclusion criteria." } := by
  unfold Spec; decide
