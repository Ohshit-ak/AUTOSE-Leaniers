import ContractForge
open ContractForge

-- 3.1.7.3/S1: When the THEMAS system detects a request for an alarm, this process shall detect which of the two alarms are being requested.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { selectedAlarm := x.alarmType }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
