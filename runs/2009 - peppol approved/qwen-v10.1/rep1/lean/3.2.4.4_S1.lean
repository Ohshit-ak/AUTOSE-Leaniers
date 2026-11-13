import ContractForge
open ContractForge

-- 3.2.4.4/S1: Description A VCD package will show its full potential only when all requested evidences (all that are necessary to prove all the requested criteria) are contained within it.
-- compiles: True · rejects_bad_example: None · checked: True

structure Evidence where
  name   : String
  content : String
  deriving DecidableEq, Repr

structure Input where
  criteria : List String
  evidences : List Evidence
  deriving DecidableEq, Repr

structure Output where
  complete : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.criteria ≠ []
  post := fun i o => o.complete = true ↔
    (∀ c ∈ i.criteria, ∃ e ∈ i.evidences, e.content.contains c)

example : Spec.pre { criteria := ["criterion1", "criterion2"], evidences := [] } ∧ Spec.post { criteria := ["criterion1", "criterion2"], evidences := [] } { complete := false } := by
  unfold Spec; decide
