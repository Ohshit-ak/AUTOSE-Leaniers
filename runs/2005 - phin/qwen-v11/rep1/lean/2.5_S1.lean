import ContractForge
open ContractForge

-- 2.5/S1: SYSTEM INTEGRATION AND DATA EXCHANGE Systems integration requirements specific to systems supporting OM are included in the section below and describe the types of data that OM should be able to send and receive.
-- compiles: True · rejects_bad_example: True · checked: True

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
