import ContractForge
open ContractForge

-- 2.2.6.10/S1: Systems supporting OM must store data about laboratory results.
-- compiles: True · rejects_bad_example: True · checked: True

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
