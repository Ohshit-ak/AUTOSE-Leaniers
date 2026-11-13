import ContractForge
open ContractForge

-- 3.1.7.3/S1: When the THEMAS system detects a request for an alarm, this process shall detect which of the two alarms are being requested.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  alarmType : String
  deriving DecidableEq, Repr

structure Output where
  isFireAlarm : Bool
  isSmokeAlarm : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.alarmType ≠ ""
  post := fun i o => 
    (o.isFireAlarm = true ↔ i.alarmType = "fire") ∧
    (o.isSmokeAlarm = true ↔ i.alarmType = "smoke") ∧
    o.isFireAlarm = false ∨ o.isSmokeAlarm = false

example : Spec.pre { alarmType := "fire" } ∧ 
          Spec.post { alarmType := "fire" }
                    { isFireAlarm := true, isSmokeAlarm := false } := by
  unfold Spec; decide
