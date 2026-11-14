import ContractForge
open ContractForge

-- 13.5.8/S1: In the case of Cab radio, details of the confirmation shall be passed to the train borne recorder if a train borne recorder is connected to the Cab radio.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  cabRadioConnected : Bool
  trainBorneRecorderConnected : Bool
  confirmationDetails : String
  deriving DecidableEq, Repr

structure Output where
  trainBorneRecorderConnected : Bool
  confirmationDetails : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cabRadioConnected = true
  post := fun i o => (o.trainBorneRecorderConnected = true ↔ i.trainBorneRecorderConnected = true) ∧
                     (o.confirmationDetails = i.confirmationDetails ↔ i.trainBorneRecorderConnected = true)

example : Spec.pre { cabRadioConnected := true, trainBorneRecorderConnected := true,
                     confirmationDetails := "Emergency call confirmed" } ∧
          Spec.post { cabRadioConnected := true, trainBorneRecorderConnected := true,
                      confirmationDetails := "Emergency call confirmed" }
                    { trainBorneRecorderConnected := true, confirmationDetails := "Emergency call confirmed" } := by
  unfold Spec; decide
