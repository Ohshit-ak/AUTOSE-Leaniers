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
  post := fun i o => o.callForTender.contains "The Call for Tender should contain the definition of specific criteria on qualitative selection and exclusion that are relevant to this particular procurement." ∧
                     (∀ c ∈ i.criteria, o.callForTender.contains c)

example : Spec.pre { criteria := ["Criterion A", "Criterion B"] } ∧
          Spec.post { criteria := ["Criterion A", "Criterion B"] }
                     { callForTender := "The Call for Tender should contain the definition of specific criteria on qualitative selection and exclusion that are relevant to this particular procurement. Criterion A. Criterion B." } := by
  unfold Spec; decide
