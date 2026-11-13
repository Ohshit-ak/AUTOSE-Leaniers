import ContractForge
open ContractForge

-- 2.2.6.3/S1: Systems supporting OM must be able to store data about the specimens/samples that are collected for laboratory testing.
-- compiles: True · rejects_bad_example: True · checked: True

structure Specimen where
  id          : Nat
  patientName : String
  collectionTime : Nat
  sampleType  : String
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
  post := fun i o => o.specimens = i.specimens ∧
                     ∀ s ∈ o.specimens, s.patientName ≠ "" ∧
                     s.collectionTime ≥ 0 ∧
                     s.sampleType ≠ "" ∧
                     s.status ∈ ["pending", "processed", "invalid"]

example : Spec.pre { specimens := [{ id := 1, patientName := "Alice", collectionTime := 15, sampleType := "blood", status := "pending" },
                                    { id := 2, patientName := "Bob", collectionTime := 20, sampleType := "urine", status := "processed" }] } ∧
          Spec.post { specimens := [{ id := 1, patientName := "Alice", collectionTime := 15, sampleType := "blood", status := "pending" },
                                    { id := 2, patientName := "Bob", collectionTime := 20, sampleType := "urine", status := "processed" }] }
                    { specimens := [{ id := 1, patientName := "Alice", collectionTime := 15, sampleType := "blood", status := "pending" },
                                    { id := 2, patientName := "Bob", collectionTime := 20, sampleType := "urine", status := "processed" }] } := by
  unfold Spec; decide
