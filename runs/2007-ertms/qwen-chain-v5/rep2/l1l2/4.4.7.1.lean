import ContractForge
open ContractForge

-- 4.4.7.1: It shall be possible to drive the train backwards in a supervised way (speed and distance) according to information received from trackside

-- L0 spec

structure Input where
  speedLimit : Nat
  distance   : Nat
  deriving DecidableEq, Repr

structure Output where
  speed : Nat
  distanceTraveled : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.speedLimit ∧ 0 < i.distance
  post := fun i o => (o.speed = i.speedLimit ∧
                      o.distanceTraveled = i.distance) ↔
                 (0 < i.speedLimit ∧ 0 < i.distance)

example : Spec.pre { speedLimit := 10, distance := 50 } ∧
          Spec.post { speedLimit := 10, distance := 50 }
                    { speed := 10, distanceTraveled := 50 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { speed := x.speedLimit, distanceTraveled := x.distance }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
