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

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { isFireAlarm := decide (x.alarmType = "fire"), isSmokeAlarm := decide (x.alarmType = "smoke") }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
