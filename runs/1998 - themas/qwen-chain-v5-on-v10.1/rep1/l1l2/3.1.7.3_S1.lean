import ContractForge
open ContractForge

-- 3.1.7.3/S1: When the THEMAS system detects a request for an alarm, this process shall detect which of the two alarms are being requested.

-- L0 spec

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

-- L1 architecture (mode=chain, success=False)

structure Mid where
  isFireAlarm : Bool
  deriving DecidableEq, Repr

def FireAlarmContract : Contract Input Mid where
  pre  := fun i => i.alarmType ≠ ""
  post := fun i m => m.isFireAlarm = true ↔ i.alarmType = "fire"

def FireAndSmokeContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => 
    (o.isFireAlarm = true ↔ m.isFireAlarm = true) ∧
    (o.isSmokeAlarm = true ↔ m.isFireAlarm = false) ∧
    o.isFireAlarm = false ∨ o.isSmokeAlarm = false
