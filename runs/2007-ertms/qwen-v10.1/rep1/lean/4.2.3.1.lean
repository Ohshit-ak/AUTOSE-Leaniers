import ContractForge
open ContractForge

-- 4.2.3.1: Using train data and infrastructure data, braking curves shall be calculated taking into account the target information but not the location of vehicles occupying the track.
-- compiles: False · rejects_bad_example: None · checked: False

structure Train where
  id      : Nat
  speed   : Nat
  braking : Nat
  deriving DecidableEq, Repr

structure Infrastructure where
  sections : List Section
  deriving DecidableEq, Repr

structure Section where
  id        : Nat
  length    : Nat
  occupied  : Option Train
  deriving DecidableEq, Repr

structure Input where
  trains   : List Train
  infra    : Infrastructure
  targetSpeed : Nat
  deriving DecidableEq, Repr

structure Output where
  brakingCurves : List (Nat × Nat)
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.trains.Nodup ∧ i.infra.sections.Nodup
  post := fun i o => 
    (∀ s ∈ i.infra.sections, 
     o.brakingCurves.length = s.length ∧
     ∀ j in i.trains.filter (fun t => t.id = s.occupied.getD none).map (fun t => t.id),
       (∃ curve ∈ o.brakingCurves, 
        curve.1 = j ∧ curve.2 = (i.targetSpeed - i.trains.filter (fun t => t.id = j).map (fun t => t.speed).sum) / s.length))

example : Spec.pre { trains := [{ id := 1, speed := 60, braking := 10 },
                                 { id := 2, speed := 50, braking := 15 }],
                     infra := { sections := [{ id := 1, length := 100, occupied := some { id := 1, speed := 60, braking := 10 }},
                                             { id := 2, length := 150, occupied := none }] },
                     targetSpeed := 70 } ∧
          Spec.post { trains := [{ id := 1, speed := 60, braking := 10 },
                                  { id := 2, speed := 50, braking := 15 }],
                      infra := { sections := [{ id := 1, length := 100, occupied := some { id := 1, speed := 60, braking := 10 }},
                                              { id := 2, length := 150, occupied := none }] },
                      targetSpeed := 70 }
                    { brakingCurves := [{ 1, 10 }, { 2, 15 }] } := by
  unfold Spec; decide
