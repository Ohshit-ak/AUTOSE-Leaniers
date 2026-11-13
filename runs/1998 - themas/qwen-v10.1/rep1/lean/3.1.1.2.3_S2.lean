import ContractForge
open ContractForge

-- 3.1.1.2.3/S2: The initialization file shall contain a unique identifier for each thermostat that the system is to monitor.
-- compiles: True · rejects_bad_example: True · checked: True

structure Thermostat where
  id : Nat
  deriving DecidableEq, Repr

structure Input where
  thermostats : List Thermostat
  deriving DecidableEq, Repr

structure Output where
  initialized : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.thermostats.Nodup
  post := fun i o => o.initialized = true ∧
                     (∀ t ∈ i.thermostats, t.id ≠ 0)

example : Spec.pre { thermostats := [{ id := 1 }, { id := 2 }] } ∧
          Spec.post { thermostats := [{ id := 1 }, { id := 2 }] }
                    { initialized := true } := by
  unfold Spec; decide
