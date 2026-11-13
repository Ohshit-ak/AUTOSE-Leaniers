import ContractForge
open ContractForge

-- 13.5.8/S1: In the case of Cab radio, details of the confirmation shall be passed to the train borne recorder if a train borne recorder is connected to the Cab radio.
-- compiles: True · rejects_bad_example: True · checked: True

structure CabRadio where
  trainBorneRecorderConnected : Bool
  deriving DecidableEq, Repr

structure Confirmation where
  details : String
  deriving DecidableEq, Repr

structure Input where
  cabRadio : CabRadio
  confirmation : Confirmation
  deriving DecidableEq, Repr

structure Output where
  trainBorneRecorderConnected : Bool
  confirmationDetails : Option String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cabRadio.trainBorneRecorderConnected
  post := fun i o => o.trainBorneRecorderConnected = i.cabRadio.trainBorneRecorderConnected ∧
                     (o.confirmationDetails = some i.confirmation.details ↔
                      i.cabRadio.trainBorneRecorderConnected = true)

example : Spec.pre { cabRadio := { trainBorneRecorderConnected := true },
                     confirmation := { details := "Emergency call confirmed" } } ∧
          Spec.post { cabRadio := { trainBorneRecorderConnected := true },
                      confirmation := { details := "Emergency call confirmed" } }
                    { trainBorneRecorderConnected := true, confirmationDetails := some "Emergency call confirmed" } := by
  unfold Spec; decide
