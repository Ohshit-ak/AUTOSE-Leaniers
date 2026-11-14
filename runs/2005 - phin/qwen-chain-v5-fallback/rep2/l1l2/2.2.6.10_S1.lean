import ContractForge
open ContractForge

-- 2.2.6.10/S1: Systems supporting OM must store data about laboratory results.

-- L0 spec

structure Specimen where
  id          : Nat
  patientName : String
  testResult  : String
  status      : String
  deriving DecidableEq, Repr

structure Input where
  specimens : List Specimen
  deriving DecidableEq, Repr

structure Output where
  specimens : List Specimen
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.specimens.Nodup
  post := fun i o => o.specimens = i.specimens.filter (fun s => s.testResult ≠ "" ∧ s.status ∈ ["Pending", "Processed", "Rejected"])

example : Spec.pre { specimens := [{ id := 1, patientName := "Alice", testResult := "Positive", status := "Processed" },
                                    { id := 2, patientName := "Bob", testResult := "Negative", status := "Processed" }] } ∧
          Spec.post { specimens := [{ id := 1, patientName := "Alice", testResult := "Positive", status := "Processed" },
                                    { id := 2, patientName := "Bob", testResult := "Negative", status := "Processed" }] }
                    { specimens := [{ id := 1, patientName := "Alice", testResult := "Positive", status := "Processed" },
                                    { id := 2, patientName := "Bob", testResult := "Negative", status := "Processed" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { specimens := x.specimens.filter (fun s => s.testResult ≠ "" ∧ s.status ∈ ["Pending", "Processed", "Rejected"]) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
