import ContractForge
open ContractForge

-- 5.2.2.19: 5.2.2.19 If a train-borne recorder is connected to the Cab radio, details of the activation, termination and any failures of the emergency function shall be sent to the train-borne recorder as each event occurs. (M)
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  emergencyActivation : Bool
  emergencyTermination : Bool
  emergencyFailure    : Bool
  trainBorneRecorder  : Option String
  deriving DecidableEq, Repr

structure Output where
  emergencyActivation : Bool
  emergencyTermination : Bool
  emergencyFailure    : Bool
  trainBorneRecorder  : Option String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.trainBorneRecorder.isSome
  post := fun i o => (o.emergencyActivation = i.emergencyActivation ∧
                      o.emergencyTermination = i.emergencyTermination ∧
                      o.emergencyFailure = i.emergencyFailure) ∧
                     (i.emergencyActivation → o.trainBorneRecorder.getD "activation" = "activation") ∧
                     (i.emergencyTermination → o.trainBorneRecorder.getD "termination" = "termination") ∧
                     (i.emergencyFailure → o.trainBorneRecorder.getD "failure" = "failure")

example : Spec.pre { emergencyActivation := true, emergencyTermination := false, emergencyFailure := false, trainBorneRecorder := some "recorder1" } ∧
          Spec.post { emergencyActivation := true, emergencyTermination := false, emergencyFailure := false, trainBorneRecorder := some "recorder1" }
                    { emergencyActivation := true, emergencyTermination := false, emergencyFailure := false, trainBorneRecorder := some "activation" } := by
  unfold Spec; decide
