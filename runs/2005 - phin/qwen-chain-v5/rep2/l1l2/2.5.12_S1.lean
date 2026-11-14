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
  isolationsQuarantines : List IsolationQuarantine
  countermeasures : List Countermeasure
  deriving DecidableEq, Repr

structure Output where
  suspectCasesCount : Nat
  isolationsQuarantinesCount : Nat
  countermeasuresCount : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.suspectCases.Nodup ∧ i.isolationsQuarantines.Nodup ∧ i.countermeasures.Nodup
  post := fun i o => o.suspectCasesCount = i.suspectCases.length ∧
                     o.isolationsQuarantinesCount = i.isolationsQuarantines.length ∧
                     o.countermeasuresCount = i.countermeasures.length

example : Spec.pre { suspectCases := [{ id := 1, location := "A", status := "suspect" }],
                     isolationsQuarantines := [{ id := 2, location := "B", status := "isolated" }],
                     countermeasures := [{ id := 3, patient := 1, type := "vaccine", status := "administered" }] } ∧
          Spec.post { suspectCases := [{ id := 1, location := "A", status := "suspect" }],
                      isolationsQuarantines := [{ id := 2, location := "B", status := "isolated" }],
                      countermeasures := [{ id := 3, patient := 1, type := "vaccine", status := "administered" }] }
                    { suspectCasesCount := 1, isolationsQuarantinesCount := 1, countermeasuresCount := 1 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { suspectCasesCount := x.suspectCases.length,
    isolationsQuarantinesCount := x.isolationsQuarantines.length,
    countermeasuresCount := x.countermeasures.length }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
