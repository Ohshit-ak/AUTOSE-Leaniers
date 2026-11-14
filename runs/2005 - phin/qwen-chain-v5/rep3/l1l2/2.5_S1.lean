import ContractForge
open ContractForge

-- 2.5/S1: SYSTEM INTEGRATION AND DATA EXCHANGE Systems integration requirements specific to systems supporting OM are included in the section below and describe the types of data that OM should be able to send and receive.

-- L0 spec

structure Input where
  outbreakData : String
  patientData  : List String
  locationData : String
  deriving DecidableEq, Repr

structure Output where
  receivedOutbreakData : String
  receivedPatientData  : List String
  receivedLocationData : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.outbreakData ≠ "" ∧ i.patientData.Nodup ∧ i.locationData ≠ ""
  post := fun i o => o.receivedOutbreakData = i.outbreakData ∧
                     o.receivedPatientData = i.patientData ∧
                     o.receivedLocationData = i.locationData

example : Spec.pre { outbreakData := "data1", patientData := ["p1", "p2"], locationData := "loc1" } ∧
          Spec.post { outbreakData := "data1", patientData := ["p1", "p2"], locationData := "loc1" }
                    { receivedOutbreakData := "data1", receivedPatientData := ["p1", "p2"], receivedLocationData := "loc1" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { receivedOutbreakData := x.outbreakData,
    receivedPatientData := x.patientData,
    receivedLocationData := x.locationData }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
