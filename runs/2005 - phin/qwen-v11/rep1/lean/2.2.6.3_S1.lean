import ContractForge
open ContractForge

-- 2.2.6.3/S1: Systems supporting OM must be able to store data about the specimens/samples that are collected for laboratory testing.
-- compiles: False · rejects_bad_example: None · checked: False

structure Specimen where
  id          : Nat
  patientName : String
  collectionDate : String
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
                     ∀ s ∈ o.specimens, s.id = i.specimens.count + 1

example : Spec.pre { specimens := [{ id := 1, patientName := "Alice", collectionDate := "2023-10-01", status := "collected" },
                                    { id := 2, patientName := "Bob", collectionDate := "2023-10-02", status := "collected" }] } ∧
          Spec.post { specimens := [{ id := 1, patientName := "Alice", collectionDate := "2023-10-01", status := "collected" },
                                     { id := 2, patientName := "Bob", collectionDate := "2023-10-02", status := "collected" }] }
                    { specimens := [{ id := 1, patientName := "Alice", collectionDate := "2023-10-01", status := "collected" },
                                    { id := 2, patientName := "Bob", collectionDate := "2023-10-02", status := "collected" }] } := by
  unfold Spec; decide
