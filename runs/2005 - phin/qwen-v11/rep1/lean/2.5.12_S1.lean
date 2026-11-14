import ContractForge
open ContractForge

-- 2.5.12/S1: Systems supporting OM should be able to provide the aggregate data necessary for health event monitoring to systems that support response tracking, such as the number of suspect cases, number of persons under isolation or quarantine, and the number of patients receiving countermeasures.
-- compiles: True · rejects_bad_example: True · checked: True

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
