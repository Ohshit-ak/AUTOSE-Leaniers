import ContractForge
open ContractForge

-- 2.2.6.6/S1: Systems supporting OM must be able to create a laboratory test request for a specimen/sample or group of specimens/samples.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { requestCreated := true,
    testRequests := x.specimens.filter (fun s => s.testType = x.testType).map (fun s => { s with status := "requested" }) }
