import ContractForge
open ContractForge

-- 3.1.1.2.1/S1: Each thermostat shall have a unique identifier by which that thermostat is identified in the THEMAS system.
-- compiles: True · rejects_bad_example: None · checked: True

structure Thermostat where
  id : Nat
  deriving DecidableEq, Repr

structure Input where
  thermostats : List Thermostat
  deriving DecidableEq, Repr

structure Output where
  thermostats : List Thermostat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.thermostats.Nodup
  post := fun i o => o.thermostats = i.thermostats ∧
                     ∀ t ∈ o.thermostats, t.id ≠ 0

example : Spec.pre { thermostats := [{ id := 1 }, { id := 2 }] } ∧
          Spec.post { thermostats := [{ id := 1 }, { id := 2 }] }
                    { thermostats := [{ id := 1 }, { id := 2 }] } := by
  unfold Spec; decide
