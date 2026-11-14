import ContractForge
open ContractForge

-- 3.2.4.4/S1: Description A VCD package will show its full potential only when all requested evidences (all that are necessary to prove all the requested criteria) are contained within it.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  evidences : List String
  criteria  : List String
  deriving DecidableEq, Repr

structure Output where
  complete : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.complete = true ↔
    (∀ c ∈ i.criteria, ∃ e ∈ i.evidences, e = c)

example : Spec.pre { evidences := ["e1", "e2", "e3"], criteria := ["c1", "c2", "c3"] } ∧ Spec.post { evidences := ["e1", "e2", "e3"], criteria := ["c1", "c2", "c3"] } { complete := false } := by
  unfold Spec; decide
