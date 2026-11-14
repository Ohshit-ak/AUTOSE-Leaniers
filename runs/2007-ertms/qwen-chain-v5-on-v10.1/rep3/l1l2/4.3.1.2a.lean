import ContractForge
open ContractForge

-- 4.3.1.2a: ETCS shall calculate the permitted speed for the train for all locations of the authorised movement.

-- L0 spec

structure Location where
  id : Nat
  speedLimit : Nat
  deriving DecidableEq, Repr

structure Input where
  locations : List Location
  deriving DecidableEq, Repr

structure Output where
  permittedSpeeds : List Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.locations.Nodup
  post := fun i o => o.permittedSpeeds.length = i.locations.length ∧
                     (∀ j ∈ i.locations, o.permittedSpeeds.contains j.speedLimit = true)

example : Spec.pre { locations := [{ id := 1, speedLimit := 80 }, { id := 2, speedLimit := 120 }] } ∧
          Spec.post { locations := [{ id := 1, speedLimit := 80 }, { id := 2, speedLimit := 120 }] }
                    { permittedSpeeds := [80, 120] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { permittedSpeeds := x.locations.map (fun l => l.speedLimit) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
