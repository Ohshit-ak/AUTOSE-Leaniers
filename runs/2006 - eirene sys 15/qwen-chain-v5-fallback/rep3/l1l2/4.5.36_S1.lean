import ContractForge
open ContractForge

-- 4.5.36/S1: Specific environmental test procedures to be followed for EIRENE mobile equipment shall include the following tests as defined in the [IEC 68] series: (M)

-- L0 spec

structure Input where
  temperature : Nat
  humidity    : Nat
  deriving DecidableEq, Repr

structure Output where
  passed     : Bool
  temperatureTestPassed : Bool
  humidityTestPassed    : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.temperature ≤ 100 ∧ i.humidity ≤ 100
  post := fun i o => (o.passed = true ↔
    (o.temperatureTestPassed = true ↔ i.temperature ≤ 50) ∧
    (o.humidityTestPassed = true ↔ i.humidity ≤ 80))

example : Spec.pre { temperature := 45, humidity := 75 } ∧
          Spec.post { temperature := 45, humidity := 75 }
                    { passed := true, temperatureTestPassed := true, humidityTestPassed := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { passed := decide (x.temperature ≤ 50 ∧ x.humidity ≤ 80),
    temperatureTestPassed := decide (x.temperature ≤ 50),
    humidityTestPassed := decide (x.humidity ≤ 80) }
