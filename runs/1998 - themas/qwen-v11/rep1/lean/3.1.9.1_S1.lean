import ContractForge
open ContractForge

-- 3.1.9.1/S1: The THEMAS system shall provide the supervisor a mechanism to change the temperature setting of any of the thermostats in the system.
-- compiles: False · rejects_bad_example: None · checked: False

structure Thermostat where
  id : Nat
  setting : Nat
  deriving DecidableEq, Repr

structure Input where
  thermostats : List Thermostat
  thermostatId : Nat
  newSetting : Nat
  deriving DecidableEq, Repr

structure Output where
  thermostats : List Thermostat
  succeeded : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.thermostatId < i.thermostats.length
  post := fun i o => o.succeeded = true ↔
    (∀ t ∈ i.thermostats, t.id = i.thermostatId → t.setting = i.newSetting) ∧
    (∀ t ∈ i.thermostats, t.id ≠ i.thermostatId → t.setting = i.thermostats.find? (·.id = t.id).get.setting)

example : Spec.pre { thermostats := [{ id := 1, setting := 20 }, { id := 2, setting := 22 }],
                     thermostatId := 1, newSetting := 21 } ∧
          Spec.post { thermostats := [{ id := 1, setting := 20 }, { id := 2, setting := 22 }],
                      thermostatId := 1, newSetting := 21 }
                    { thermostats := [{ id := 1, setting := 21 }, { id := 2, setting := 22 }], succeeded := true } := by
  unfold Spec; decide
