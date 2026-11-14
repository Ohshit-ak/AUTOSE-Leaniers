import ContractForge
open ContractForge

-- 3.12.6/S1: After emplacement at the operational site, the TCS shall be capable of planning and launching a mission within 1 hour of tasking. [SSS441] Required activities include 1) mission planning of a minimum 1 waypoint mission, 2) preparing 2 AVs for flight, 3) data terminal set-up, 4) safety equipment emplaced, 5) and a single AV launched.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  missionPlanned : Bool
  avsPrepared : Bool
  dataTerminalSetUp : Bool
  safetyEquipmentEmplaced : Bool
  avLaunched : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros ≤ 3600000000 ∧
                     o.missionPlanned = true ∧
                     o.avsPrepared = true ∧
                     o.dataTerminalSetUp = true ∧
                     o.safetyEquipmentEmplaced = true ∧
                     o.avLaunched = true

example : Spec.pre { } ∧
          Spec.post { } { elapsedMicros := 3500000000,
                          missionPlanned := true,
                          avsPrepared := true,
                          dataTerminalSetUp := true,
                          safetyEquipmentEmplaced := true,
                          avLaunched := true } := by
  unfold Spec; decide
