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
  deriving DecidableEq, Repr

structure Output where
  requestCreated : Bool
  testRequests   : List Specimen
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.specimens.Nodup ∧ i.testType ≠ ""
  post := fun i o => o.requestCreated = true ↔
    ∃ s ∈ i.specimens, s.testType = i.testType ∧
    (o.testRequests = [s] ∧ s.status = "requested" ∨
     o.testRequests = i.specimens.map (fun s => { s with status := "requested" }) ∧
     o.testRequests.length = i.specimens.length)

example : Spec.pre { specimens := [{ id := 1, patientName := "Alice", testType := "flu", status := "collected" }],
                     testType := "flu" } ∧
          Spec.post { specimens := [{ id := 1, patientName := "Alice", testType := "flu", status := "collected" }],
                      testType := "flu" }
                    { requestCreated := true, testRequests := [{ id := 1, patientName := "Alice", testType := "flu", status := "requested" }] } := by
  unfold Spec; decide
