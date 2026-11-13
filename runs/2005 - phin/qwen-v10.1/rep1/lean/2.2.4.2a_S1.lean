import ContractForge
open ContractForge

-- 2.2.4.2a/S1: Case data about the entity should include: a case identifier (i.e., Case ID) that is unique within the jurisdiction being reported, the suspected agent, case diagnosis, health status (e.g., no symptoms, acute illness), case status (e.g., confirmed, probable, suspect), investigation dates, clinical history, symptom onset date and time, epidemiological links to other cases, and priority (e.g., high, medium, low).
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  caseId         : String
  jurisdiction   : String
  suspectedAgent : String
  diagnosis      : String
  healthStatus   : String
  caseStatus     : String
  investigationDates : List String
  clinicalHistory : String
  symptomOnset   : String
  epidemiologicalLinks : List String
  priority        : String
  deriving DecidableEq, Repr

structure Output where
  caseId         : String
  jurisdiction   : String
  suspectedAgent : String
  diagnosis      : String
  healthStatus   : String
  caseStatus     : String
  investigationDates : List String
  clinicalHistory : String
  symptomOnset   : String
  epidemiologicalLinks : List String
  priority        : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 
    i.caseId ≠ "" ∧
    i.suspectedAgent ≠ "" ∧
    i.diagnosis ≠ "" ∧
    i.healthStatus ≠ "" ∧
    i.caseStatus ≠ "" ∧
    i.investigationDates.Nodup ∧
    i.symptomOnset ≠ "" ∧
    i.epidemiologicalLinks.Nodup ∧
    i.priority ≠ ""
  post := fun i o => 
    o.caseId = i.caseId ∧
    o.jurisdiction = i.jurisdiction ∧
    o.suspectedAgent = i.suspectedAgent ∧
    o.diagnosis = i.diagnosis ∧
    o.healthStatus = i.healthStatus ∧
    o.caseStatus = i.caseStatus ∧
    o.investigationDates = i.investigationDates ∧
    o.clinicalHistory = i.clinicalHistory ∧
    o.symptomOnset = i.symptomOnset ∧
    o.epidemiologicalLinks = i.epidemiologicalLinks ∧
    o.priority = i.priority

example : Spec.pre { caseId := "123", jurisdiction := "NY", suspectedAgent := "Virus X", 
                     diagnosis := "Influenza", healthStatus := "Acute illness", 
                     caseStatus := "Confirmed", investigationDates := ["2023-01-01"], 
                     clinicalHistory := "History of recent travel", 
                     symptomOnset := "2023-01-01T12:00", 
                     epidemiologicalLinks := ["Case 456"], 
                     priority := "High" } ∧
          Spec.post { caseId := "123", jurisdiction := "NY", suspectedAgent := "Virus X", 
                      diagnosis := "Influenza", healthStatus := "Acute illness", 
                      caseStatus := "Confirmed", investigationDates := ["2023-01-01"], 
                      clinicalHistory := "History of recent travel", 
                      symptomOnset := "2023-01-01T12:00", 
                      epidemiologicalLinks := ["Case 456"], 
                      priority := "High" }
                    { caseId := "123", jurisdiction := "NY", suspectedAgent := "Virus X", 
                      diagnosis := "Influenza", healthStatus := "Acute illness", 
                      caseStatus := "Confirmed", investigationDates := ["2023-01-01"], 
                      clinicalHistory := "History of recent travel", 
                      symptomOnset := "2023-01-01T12:00", 
                      epidemiologicalLinks := ["Case 456"], 
                      priority := "High" } := by
  unfold Spec; decide
