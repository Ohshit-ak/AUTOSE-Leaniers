import ContractForge
open ContractForge

-- 3.1.1.2.1/S1: Each thermostat shall have a unique identifier by which that thermostat is identified in the THEMAS system.

-- L0 spec

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
  pre  := fun i => i.thermostats.Nodup ∧ i.thermostats.all (fun t => 0 < t.id)
  post := fun i o => o.thermostats = i.thermostats ∧
                     ∀ t ∈ o.thermostats, 0 < t.id

example : Spec.pre { thermostats := [{ id := 1 }, { id := 2 }] } ∧
          Spec.post { thermostats := [{ id := 1 }, { id := 2 }] }
                    { thermostats := [{ id := 1 }, { id := 2 }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { thermostats := x.thermostats }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
