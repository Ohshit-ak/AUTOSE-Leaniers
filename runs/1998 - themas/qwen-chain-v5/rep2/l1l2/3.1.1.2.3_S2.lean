import ContractForge
open ContractForge

-- 3.1.1.2.3/S2: The initialization file shall contain a unique identifier for each thermostat that the system is to monitor.

-- L0 spec

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
  pre  := fun i => i.thermostats.Nodup ∧ i.thermostats.all (fun t => t.id ≠ 0)
  post := fun i o => o.initialized = true

example : Spec.pre { thermostats := [{ id := 1 }, { id := 2 }] } ∧
          Spec.post { thermostats := [{ id := 1 }, { id := 2 }] }
                    { initialized := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { initialized := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
