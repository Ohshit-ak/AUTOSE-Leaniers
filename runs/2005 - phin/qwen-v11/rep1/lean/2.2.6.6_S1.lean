import ContractForge
open ContractForge

-- 2.2.6.6/S1: Systems supporting OM must be able to create a laboratory test request for a specimen/sample or group of specimens/samples.
-- compiles: True · rejects_bad_example: True · checked: True

structure Specimen where
  id          : Nat
  patientName : String
  testType    : String
  status      : String
  deriving DecidableEq, Repr

structure Input where
  specimens : List Specimen
  testType  : String
  patientName : String
  deriving DecidableEq, Repr

structure Output where
  requestCreated : Bool
  testRequest : Specimen
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.specimens.Nodup ∧ i.patientName ≠ "" ∧ i.testType ≠ ""
  post := fun i o => o.requestCreated = true ↔
    ∃ s ∈ i.specimens, s.patientName = i.patientName ∧ s.testType = i.testType ∧
    o.testRequest = { id := s.id, patientName := s.patientName, testType := s.testType, status := "requested" } ∧
    o.requestCreated = true → o.testRequest.status = "requested"

example : Spec.pre { specimens := [{ id := 1, patientName := "John Doe", testType := "Blood Test", status := "collected" }],
                     testType := "Blood Test", patientName := "John Doe" } ∧
          Spec.post { specimens := [{ id := 1, patientName := "John Doe", testType := "Blood Test", status := "collected" }],
                      testType := "Blood Test", patientName := "John Doe" }
                    { requestCreated := true, testRequest := { id := 1, patientName := "John Doe", testType := "Blood Test", status := "requested" } } := by
  unfold Spec; decide
