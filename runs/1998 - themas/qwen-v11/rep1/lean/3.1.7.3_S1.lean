import ContractForge
open ContractForge

-- 3.1.7.3/S1: When the THEMAS system detects a request for an alarm, this process shall detect which of the two alarms are being requested.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  alarmType : String
  deriving DecidableEq, Repr

structure Output where
  selectedAlarm : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.alarmType ∈ ["alarm1", "alarm2"]
  post := fun i o => o.selectedAlarm = i.alarmType ∧
                     (o.selectedAlarm = "alarm1" ↔ i.alarmType = "alarm1") ∧
                     (o.selectedAlarm = "alarm2" ↔ i.alarmType = "alarm2")

example : Spec.pre { alarmType := "alarm1" } ∧
          Spec.post { alarmType := "alarm1" }
                    { selectedAlarm := "alarm1" } := by
  unfold Spec; decide
