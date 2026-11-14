import ContractForge
open ContractForge

-- 2.2.6.10/S1: Systems supporting OM must store data about laboratory results.

-- L0 spec

structure Specimen where
  id          : Nat
  patientName : String
  testResult  : String
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
                     ∀ s ∈ o.specimens, s.testResult ≠ ""

example : Spec.pre { specimens := [{ id := 1, patientName := "Alice", testResult := "Positive" },
                                    { id := 2, patientName := "Bob", testResult := "Negative" }] } ∧
          Spec.post { specimens := [{ id := 1, patientName := "Alice", testResult := "Positive" },
                                     { id := 2, patientName := "Bob", testResult := "Negative" }] }
                    { specimens := [{ id := 1, patientName := "Alice", testResult := "Positive" },
                                    { id := 2, patientName := "Bob", testResult := "Negative" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { specimens := x.specimens.filter (fun s => s.testResult ≠ "")
  }
