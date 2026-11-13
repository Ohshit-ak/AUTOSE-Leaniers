import ContractForge
open ContractForge

-- 3.1.2.9/S1: Description If an economic operator decides to participate in a particular Call for Tender he can directly retrieve information about relevant evidences and related criteria by using the information published in the Call for Tender.
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  evidences : List String
  criteria  : List String
  relevant  : List String
  deriving DecidableEq, Repr

structure Output where
  evidences : List String
  criteria  : List String
  deriving DecidableEq, Repr

-- An evidence or criterion is relevant if it is in the relevant field of the input
def IsRelevant (e : String) (relevant : List String) : Bool :=
  relevant.contains e

def Spec : Contract Input Output where
  pre  := fun i => i.relevant ≠ []
  post := fun i o => (o.evidences = i.evidences ∧ o.criteria = i.criteria) ↔
                     (i.relevant.all (fun e => IsRelevant e i.evidences) ∧
                      i.relevant.all (fun e => IsRelevant e i.criteria))

example : Spec.pre { evidences := ["e1", "e2"], criteria := ["c1", "c2"], relevant := ["e1", "c1"] } ∧
          Spec.post { evidences := ["e1", "e2"], criteria := ["c1", "c2"], relevant := ["e1", "c1"] }
                    { evidences := ["e1"], criteria := ["c1"] } := by
  unfold Spec; decide
