import ContractForge
open ContractForge

-- 2.2.2.4/S1: Systems supporting OM should have the ability to capture changes to the case definition that occur as the health event evolves.
-- compiles: True · rejects_bad_example: None · checked: True

structure CaseDefinition where
  criteria : String
  deriving DecidableEq, Repr

structure HealthEvent where
  caseDefinitions : List CaseDefinition
  deriving DecidableEq, Repr

structure Input where
  caseDefinitions : List CaseDefinition
  deriving DecidableEq, Repr

structure Output where
  caseDefinitions : List CaseDefinition
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.caseDefinitions.Nodup
  post := fun i o => o.caseDefinitions = i.caseDefinitions ∧
                     o.caseDefinitions.Nodup

example : Spec.pre { caseDefinitions := [{ criteria := "Symptom A" },
                                          { criteria := "Symptom B" }] } ∧
          Spec.post { caseDefinitions := [{ criteria := "Symptom A" },
                                          { criteria := "Symptom B" }] }
                    { caseDefinitions := [{ criteria := "Symptom A" },
                                          { criteria := "Symptom B" }] } := by
  unfold Spec; decide
