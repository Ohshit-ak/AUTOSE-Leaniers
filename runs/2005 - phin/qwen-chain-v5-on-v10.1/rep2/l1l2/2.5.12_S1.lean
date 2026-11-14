import ContractForge
open ContractForge

-- 2.5.12/S1: Systems supporting OM should be able to provide the aggregate data necessary for health event monitoring to systems that support response tracking, such as the number of suspect cases, number of persons under isolation or quarantine, and the number of patients receiving countermeasures.

-- L0 spec

structure SuspectCase where
  id : Nat
  location : String
  status : String
  deriving DecidableEq, Repr

structure IsolationQuarantine where
  id : Nat
  location : String
  status : String
  deriving DecidableEq, Repr

structure Countermeasure where
  id : Nat
  patient : Nat
  type : String
  status : String
  deriving DecidableEq, Repr

structure Input where
  suspectCases : List SuspectCase
  isolationQuarantines : List IsolationQuarantine
  countermeasures : List Countermeasure
  deriving DecidableEq, Repr

structure Output where
  suspectCasesCount : Nat
  isolationQuarantinesCount : Nat
  countermeasuresCount : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.suspectCases.Nodup ∧ i.isolationQuarantines.Nodup ∧ i.countermeasures.Nodup
  post := fun i o => (o.suspectCasesCount = i.suspectCases.length ↔ i.suspectCases.length > 0) ∧
                     (o.isolationQuarantinesCount = i.isolationQuarantines.length ↔ i.isolationQuarantines.length > 0) ∧
                     (o.countermeasuresCount = i.countermeasures.length ↔ i.countermeasures.length > 0)

example : Spec.pre { suspectCases := [{ id := 1, location := "A", status := "suspect" }], isolationQuarantines := [{ id := 2, location := "B", status := "quarantine" }], countermeasures := [{ id := 3, patient := 1, type := "vaccine", status := "administered" }] } ∧ Spec.post { suspectCases := [{ id := 1, location := "A", status := "suspect" }], isolationQuarantines := [{ id := 2, location := "B", status := "quarantine" }], countermeasures := [{ id := 3, patient := 1, type := "vaccine", status := "administered" }] } { suspectCasesCount := 1, isolationQuarantinesCount := 1, countermeasuresCount := 1 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { suspectCasesCount := if x.suspectCases.length > 0 then x.suspectCases.length else 0,
    isolationQuarantinesCount := if x.isolationQuarantines.length > 0 then x.isolationQuarantines.length else 0,
    countermeasuresCount := if x.countermeasures.length > 0 then x.countermeasures.length else 0 }
