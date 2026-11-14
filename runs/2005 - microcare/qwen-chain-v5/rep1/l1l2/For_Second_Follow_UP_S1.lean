import ContractForge
open ContractForge

-- For Second Follow UP/S1: The system will have the provision to enter any number of Syndrome, Clinical Examinations, Diagnosis, Lab Test, Drugs and Other Measures in any treatment level based on MSIU treatment master.

-- L0 spec

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
  deriving DecidableEq, Repr

structure Output where
  syndromes : List Syndrome
  clinicalExaminations : List ClinicalExamination
  diagnoses : List Diagnosis
  labTests : List LabTest
  drugs : List Drug
  otherMeasures : List OtherMeasure
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => 
    o.syndromes.length = i.syndromes.length ∧
    o.clinicalExaminations.length = i.clinicalExaminations.length ∧
    o.diagnoses.length = i.diagnoses.length ∧
    o.labTests.length = i.labTests.length ∧
    o.drugs.length = i.drugs.length ∧
    o.otherMeasures.length = i.otherMeasures.length ∧
    o.syndromes = i.syndromes ∧
    o.clinicalExaminations = i.clinicalExaminations ∧
    o.diagnoses = i.diagnoses ∧
    o.labTests = i.labTests ∧
    o.drugs = i.drugs ∧
    o.otherMeasures = i.otherMeasures

example : Spec.pre { syndromes := [{ code := "S1", description := "Syndrome 1" }],
                     clinicalExaminations := [{ code := "CE1", description := "Clinical Exam 1" }],
                     diagnoses := [{ code := "D1", description := "Diagnosis 1" }],
                     labTests := [{ code := "LT1", description := "Lab Test 1" }],
                     drugs := [{ code := "D2", description := "Drug 2" }],
                     otherMeasures := [{ code := "OM1", description := "Other Measure 1" }] } ∧
          Spec.post { syndromes := [{ code := "S1", description := "Syndrome 1" }],
                      clinicalExaminations := [{ code := "CE1", description := "Clinical Exam 1" }],
                      diagnoses := [{ code := "D1", description := "Diagnosis 1" }],
                      labTests := [{ code := "LT1", description := "Lab Test 1" }],
                      drugs := [{ code := "D2", description := "Drug 2" }],
                      otherMeasures := [{ code := "OM1", description := "Other Measure 1" }] }
                    { syndromes := [{ code := "S1", description := "Syndrome 1" }],
                       clinicalExaminations := [{ code := "CE1", description := "Clinical Exam 1" }],
                       diagnoses := [{ code := "D1", description := "Diagnosis 1" }],
                       labTests := [{ code := "LT1", description := "Lab Test 1" }],
                       drugs := [{ code := "D2", description := "Drug 2" }],
                       otherMeasures := [{ code := "OM1", description := "Other Measure 1" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { syndromes := x.syndromes,
    clinicalExaminations := x.clinicalExaminations,
    diagnoses := x.diagnoses,
    labTests := x.labTests,
    drugs := x.drugs,
    otherMeasures := x.otherMeasures }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
