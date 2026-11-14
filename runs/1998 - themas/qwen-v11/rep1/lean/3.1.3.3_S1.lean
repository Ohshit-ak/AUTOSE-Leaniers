import ContractForge
open ContractForge

-- 3.1.3.3/S1: Two types of temperature data shall be recognized from the thermostats: 1) the temperature setting and 2) the current temperature.
-- compiles: True · rejects_bad_example: True · checked: True

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
