import ContractForge
open ContractForge

-- 5.2.2.19: 5.2.2.19 If a train-borne recorder is connected to the Cab radio, details of the activation, termination and any failures of the emergency function shall be sent to the train-borne recorder as each event occurs. (M)
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  emergencyActivation : Bool
  emergencyTermination : Bool
  emergencyFailure    : Bool
  deriving DecidableEq, Repr

structure Output where
  emergencyActivation : Bool
  emergencyTermination : Bool
  emergencyFailure    : Bool
  trainBorneRecorder  : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.emergencyActivation ∨ i.emergencyTermination ∨ i.emergencyFailure
  post := fun i o =>
    (o.emergencyActivation = i.emergencyActivation ∧
     o.emergencyTermination = i.emergencyTermination ∧
     o.emergencyFailure = i.emergencyFailure) ∧
    (o.trainBorneRecorder.length = 3 ∧
     o.trainBorneRecorder[0] = "Activation" ↔ i.emergencyActivation = true) ∧
    (o.trainBorneRecorder[1] = "Termination" ↔ i.emergencyTermination = true) ∧
    (o.trainBorneRecorder[2] = "Failure" ↔ i.emergencyFailure = true)

example : Spec.pre { emergencyActivation := true, emergencyTermination := false, emergencyFailure := false } ∧
          Spec.post { emergencyActivation := true, emergencyTermination := false, emergencyFailure := false }
                     { emergencyActivation := true, emergencyTermination := false, emergencyFailure := false,
                       trainBorneRecorder := ["Activation", "Termination", "Failure"] } := by
  unfold Spec; decide
