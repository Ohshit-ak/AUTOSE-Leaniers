import ContractForge
open ContractForge

-- 3.1.2.8/S3: If an economic operator decides to participate in a particular Call for Tender he can directly retrieve the relevant criteria and evidences by using the information published in the Call for Tender.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  criteria : List String
  evidences : List String
  deriving DecidableEq, Repr

structure Output where
  relevantCriteria : List String
  relevantEvidences : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.criteria ≠ [] ∧ i.evidences ≠ []
  post := fun i o => o.relevantCriteria = i.criteria ∧
                     o.relevantEvidences = i.evidences

example : Spec.pre { criteria := ["Criterion A", "Criterion B"], evidences := ["Evidence 1", "Evidence 2"] } ∧
          Spec.post { criteria := ["Criterion A", "Criterion B"], evidences := ["Evidence 1", "Evidence 2"] }
                    { relevantCriteria := ["Criterion A", "Criterion B"], relevantEvidences := ["Evidence 1", "Evidence 2"] } := by
  unfold Spec; decide
