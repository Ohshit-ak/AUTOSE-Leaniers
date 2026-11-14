import ContractForge
open ContractForge

-- 3.3.2.4/S2: The Call for Tender should contain the definition of specific criteria on qualitative selection and exclusion that are relevant to this particular procurement.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  criteria : List String
  deriving DecidableEq, Repr

structure Output where
  callForTender : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.criteria.length > 0
  post := fun i o => o.callForTender.containsAll i.criteria

example : Spec.pre { criteria := ["quality", "experience", "references"] } ∧
          Spec.post { criteria := ["quality", "experience", "references"] }
                     { callForTender := "This Call for Tender includes the following criteria: quality, experience, references." } := by
  unfold Spec; decide
