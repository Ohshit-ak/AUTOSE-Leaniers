import ContractForge
open ContractForge

-- 3.1.3.3/S1: Two types of temperature data shall be recognized from the thermostats: 1) the temperature setting and 2) the current temperature.

-- L0 spec

structure Input where
  temperatureSetting : Nat
  currentTemperature : Nat
  deriving DecidableEq, Repr

structure Output where
  temperatureSetting : Nat
  currentTemperature : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => (o.temperatureSetting = i.temperatureSetting ∧
                      o.currentTemperature = i.currentTemperature) ∧
                     (o.temperatureSetting ≠ i.temperatureSetting →
                      o.temperatureSetting = i.temperatureSetting) ∧
                     (o.currentTemperature ≠ i.currentTemperature →
                      o.currentTemperature = i.currentTemperature)

example : Spec.pre { temperatureSetting := 23, currentTemperature := 20 } ∧
          Spec.post { temperatureSetting := 23, currentTemperature := 20 }
                    { temperatureSetting := 23, currentTemperature := 20 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { temperatureSetting := x.temperatureSetting,
    currentTemperature := x.currentTemperature }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
