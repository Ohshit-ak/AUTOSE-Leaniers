import ContractForge
open ContractForge

-- 4.4.7.1: It shall be possible to drive the train backwards in a supervised way (speed and distance) according to information received from trackside
-- compiles: True · rejects_bad_example: True · checked: True

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
  post := fun i o => (o.speed = i.speedLimit ∧ o.distanceTraveled = i.distance) ↔
                     (0 < i.speedLimit ∧ 0 < i.distance)

example : Spec.pre { speedLimit := 10, distance := 50 } ∧
          Spec.post { speedLimit := 10, distance := 50 }
                    { speed := 10, distanceTraveled := 50 } := by
  unfold Spec; decide
