import ContractForge
open ContractForge

-- 7.2.2.12: 7.2.2.12 If the emergency call function is disabled, a visual indication and short audible indication shall be given when: the radio is switched on; (M) the emergency button is pushed (in this case nothing else will happen). (M) Receive incoming point to point voice call

-- L0 spec

structure Input where
  emergencyCallEnabled : Bool
  emergencyButtonPushed : Bool
  deriving DecidableEq, Repr

structure Output where
  visualIndication : Bool
  audibleIndication : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => ¬i.emergencyCallEnabled
  post := fun i o => (o.visualIndication = true ∧ o.audibleIndication = true) ↔
                     (i.emergencyButtonPushed = true ∧ i.emergencyCallEnabled = false)

example : Spec.pre { emergencyCallEnabled := false, emergencyButtonPushed := true } ∧
          Spec.post { emergencyCallEnabled := false, emergencyButtonPushed := true }
                    { visualIndication := true, audibleIndication := true } := by
  unfold Spec; decide

def whenEmergencyCallDisabled (i : Input) : Bool :=
  i.emergencyCallEnabled = false

def whenEmergencyButtonPushed (i : Input) : Bool :=
  i.emergencyButtonPushed = true

def computeOutput (i : Input) : Output :=
  { visualIndication := whenEmergencyButtonPushed i,
    audibleIndication := whenEmergencyButtonPushed i }

example : Spec.pre { emergencyCallEnabled := false, emergencyButtonPushed := true } ∧
          Spec.post { emergencyCallEnabled := false, emergencyButtonPushed := true }
                    { visualIndication := true, audibleIndication := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { visualIndication := x.emergencyButtonPushed ∧ ¬x.emergencyCallEnabled,
    audibleIndication := x.emergencyButtonPushed ∧ ¬x.emergencyCallEnabled }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
