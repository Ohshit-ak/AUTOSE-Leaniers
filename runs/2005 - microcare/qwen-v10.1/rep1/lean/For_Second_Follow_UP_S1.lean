import ContractForge
open ContractForge

-- For Second Follow UP/S1: The system will have the provision to enter any number of Syndrome, Clinical Examinations, Diagnosis, Lab Test, Drugs and Other Measures in any treatment level based on MSIU treatment master.
-- compiles: False · rejects_bad_example: None · checked: False

structure Syndrome where
  code : String
  description : String
  deriving DecidableEq, Repr

structure ClinicalExamination where
  code : String
  description : String
  deriving DecidableEq, Repr

structure Diagnosis where
  code : String
  description : String
  deriving DecidableEq, Repr

structure LabTest where
  code : String
  description : String
  deriving DecidableEq, Repr

structure Drug where
  code : String
  description : String
  deriving DecidableEq, Repr

structure OtherMeasure where
  code : String
  description : String
  deriving DecidableEq, Repr

structure Input where
  syndromes : List Syndrome
  clinicalExaminations : List ClinicalExamination
  diagnoses : List Diagnosis
  labTests : List LabTest
  drugs : List Drug
  otherMeasures : List OtherMeasure
  treatmentLevel : Nat
  deriving DecidableEq, Repr

structure Output where
  syndromes : List Syndrome
  clinicalExaminations : List ClinicalExamination
  diagnoses : List Diagnosis
  labTests : List LabTest
  drugs : List Drug
  otherMeasures : List OtherMeasure
  treatmentLevel : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.treatmentLevel > 0
  post := fun i o => o.syndromes = i.syndromes ∧
                     o.clinicalExaminations = i.clinicalExaminations ∧
                     o.diagnoses = i.diagnoses ∧
                     o.labTests = i.labTests ∧
                     o.drugs = i.drugs ∧
                     o.otherMeasures = i.otherMeasures ∧
                     o.treatmentLevel = i.treatmentLevel

example : Spec.pre { syndromes := [{ code := "S1", description := "Syndrome 1" }],
                     clinicalExaminations := [{ code := "CE1", description := "Clinical Exam 1" }],
                     diagnoses := [{ code := "D1", description := "Diagnosis 1" }],
                     labTests := [{ code := "LT1", description := "Lab Test 1" }],
                     drugs := [{ code := "D1", description := "Drug 1" }],
                     otherMeasures := [{ code := "OM1", description := "Other Measure 1" }],
                     treatmentLevel := 1 } ∧
          Spec.post { syndromes := [{ code := "S1", description := "Syndrome 1" }],
                      clinicalExaminations := [{ code := "CE1", description := "Clinical Exam 1" }],
                      diagnoses := [{ code := "D1", description := "Diagnosis 1" }],
                      labTests := [{ code := "LT1", description := "Lab Test 1" }],
                      drugs := [{ code := "D1", description := "Drug 1" }],
                      otherMeasures := [{ code := "OM1", description := "Other Measure 1" }],
                      treatmentLevel := 1 } := by
  unfold Spec; decide
