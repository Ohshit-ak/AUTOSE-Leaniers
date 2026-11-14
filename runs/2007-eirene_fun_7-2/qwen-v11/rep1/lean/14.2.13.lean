import ContractForge
open ContractForge

-- 14.2.13: 14.2.13 It should be possible for the system to record: (O) shunting group composition at a given instant; the source and time a shunting emergency call was transmitted; the recipients of a shunting emergency call.
-- compiles: True · rejects_bad_example: True · checked: True

structure ShuntingGroup where
  composition : List String
  deriving DecidableEq, Repr

structure EmergencyCall where
  source : String
  time   : Nat
  recipients : List String
  deriving DecidableEq, Repr

structure Input where
  shuntingGroup : ShuntingGroup
  emergencyCall : Option EmergencyCall
  deriving DecidableEq, Repr

structure Output where
  recordedShuntingGroup : ShuntingGroup
  recordedEmergencyCall : Option EmergencyCall
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.recordedShuntingGroup = i.shuntingGroup ∧
                     (o.recordedEmergencyCall = i.emergencyCall ↔
                      i.emergencyCall.isSome) ∧
                     (o.recordedEmergencyCall = i.emergencyCall →
                      o.recordedEmergencyCall.getD { source := "", time := 0, recipients := [] } = i.emergencyCall.getD { source := "", time := 0, recipients := [] })

example : Spec.pre { shuntingGroup := { composition := ["locomotive", "wagons"] },
                     emergencyCall := some { source := "control room", time := 15, recipients := ["engineer", "dispatcher"] } } ∧
          Spec.post { shuntingGroup := { composition := ["locomotive", "wagons"] },
                      emergencyCall := some { source := "control room", time := 15, recipients := ["engineer", "dispatcher"] } }
                    { recordedShuntingGroup := { composition := ["locomotive", "wagons"] },
                      recordedEmergencyCall := some { source := "control room", time := 15, recipients := ["engineer", "dispatcher"] } } := by
  unfold Spec; decide
