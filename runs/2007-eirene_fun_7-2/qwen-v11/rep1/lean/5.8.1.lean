import ContractForge
open ContractForge

-- 5.8.1: 5.8.1 The Cab radio shall be able to provide the following information to a train-borne recorder or other equipment via a standardised interface: activation of Cab radio emergency call button; (M) receipt of incoming Railway emergency call; (M) termination of outgoing or incoming Railway emergency call; (M) radio faults; (O) driver safety device alarm message transmission; (M) details of confirmation of Railway emergency call. (M)
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  emergencyCallActivation : Bool
  incomingEmergencyCall   : Bool
  outgoingEmergencyCall   : Bool
  radioFaults             : Bool
  driverSafetyDeviceAlarm : Bool
  confirmationDetails    : String
  deriving DecidableEq, Repr

structure Output where
  emergencyCallActivation : Bool
  incomingEmergencyCall   : Bool
  outgoingEmergencyCall   : Bool
  radioFaults             : Bool
  driverSafetyDeviceAlarm : Bool
  confirmationDetails    : String
  deriving DecidableEq, Repr

-- IMPL: Standardised interface for Cab radio to train-borne recorder

def Spec : Contract Input Output where
  pre  := fun i => i.emergencyCallActivation ∨ i.incomingEmergencyCall ∨
                   i.outgoingEmergencyCall ∨ i.radioFaults ∨
                   i.driverSafetyDeviceAlarm ∨ i.confirmationDetails ≠ ""
  post := fun i o => (o.emergencyCallActivation = i.emergencyCallActivation) ∧
                     (o.incomingEmergencyCall = i.incomingEmergencyCall) ∧
                     (o.outgoingEmergencyCall = i.outgoingEmergencyCall) ∧
                     (o.radioFaults = i.radioFaults) ∧
                     (o.driverSafetyDeviceAlarm = i.driverSafetyDeviceAlarm) ∧
                     (o.confirmationDetails = i.confirmationDetails) ∧
                     (o.confirmationDetails = "" ↔ i.confirmationDetails = "") ∧
                     (o.emergencyCallActivation = true ↔ i.emergencyCallActivation = true) ∧
                     (o.incomingEmergencyCall = true ↔ i.incomingEmergencyCall = true) ∧
                     (o.outgoingEmergencyCall = true ↔ i.outgoingEmergencyCall = true) ∧
                     (o.radioFaults = true ↔ i.radioFaults = true) ∧
                     (o.driverSafetyDeviceAlarm = true ↔ i.driverSafetyDeviceAlarm = true)

example : Spec.pre { emergencyCallActivation := true, incomingEmergencyCall := false, outgoingEmergencyCall := false, radioFaults := false, driverSafetyDeviceAlarm := false, confirmationDetails := "" } ∧
          Spec.post { emergencyCallActivation := true, incomingEmergencyCall := false, outgoingEmergencyCall := false, radioFaults := false, driverSafetyDeviceAlarm := false, confirmationDetails := "" } { emergencyCallActivation := true, incomingEmergencyCall := false, outgoingEmergencyCall := false, radioFaults := false, driverSafetyDeviceAlarm := false, confirmationDetails := "" } := by
  unfold Spec; decide
