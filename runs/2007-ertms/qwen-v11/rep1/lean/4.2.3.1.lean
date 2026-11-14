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
  target   : Nat
  deriving DecidableEq, Repr

structure Output where
  brakingCurves : List (Nat × Nat)
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.trains.Nodup ∧ i.infra.sections.Nodup
  post := fun i o => 
    (∀ s ∈ i.infra.sections, 
     o.brakingCurves.length = s.length ∧
     ∀ j in s.length, 
       (j < s.length - 1 → o.brakingCurves[j].1 = i.target ∧ o.brakingCurves[j].2 = i.target - j) ∧
       (j = s.length - 1 → o.brakingCurves[j].1 = i.target ∧ o.brakingCurves[j].2 = 0)) ∧
    (∀ s ∈ i.infra.sections, 
     s.occupied.isNone → 
       o.brakingCurves.length = s.length ∧
       ∀ j in s.length, 
         (j < s.length - 1 → o.brakingCurves[j].1 = i.target ∧ o.brakingCurves[j].2 = i.target - j) ∧
         (j = s.length - 1 → o.brakingCurves[j].1 = i.target ∧ o.brakingCurves[j].2 = 0))

example : Spec.pre { trains := [{ id := 1, speed := 50, braking := 10 },
                                 { id := 2, speed := 60, braking := 15 }],
                     infra := { sections := [{ id := 1, length := 100, occupied := none },
                                             { id := 2, length := 150, occupied := none }] },
                     target := 50 } ∧
          Spec.post { trains := [{ id := 1, speed := 50, braking := 10 },
                                 { id := 2, speed := 60, braking := 15 }],
                      infra := { sections := [{ id := 1, length := 100, occupied := none },
                                              { id := 2, length := 150, occupied := none }] },
                      target := 50 }
                    { brakingCurves := [{ (0, 50), (1, 49), (2, 48), (3, 47), (4, 46), (5, 45), (6, 44), (7, 43), (8, 42), (9, 41) },
                                        { (0, 50), (1, 49), (2, 48), (3, 47), (4, 46), (5, 45), (6, 44), (7, 43), (8, 42), (9, 41), (10, 40), (11, 39), (12, 38), (13, 37), (14, 36), (15, 35), (16, 34), (17, 33), (18, 32), (19, 31), (20, 30), (21, 29), (22, 28), (23, 27), (24, 26), (25, 25), (26, 24), (27, 23), (28, 22), (29, 21), (30, 20), (31, 19), (32, 18), (33, 17), (34, 16), (35, 15), (36, 14), (37, 13), (38, 12), (39, 11), (40, 10), (41, 9), (42, 8), (43, 7), (44, 6), (45, 5), (46, 4), (47, 3), (48, 2), (49, 1) }] } } := by
  unfold Spec; decide
