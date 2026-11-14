import ContractForge
open ContractForge

-- 5.2.2.57: 5.2.2.57 If a train-borne recorder is connected to the Cab radio, details of an incoming Railway emergency call shall be transmitted to the train-borne recorder for recording, see section 5.8. (M) Confirm receipt of Railway emergency call
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  recorderConnected : Bool
  railwayEmergencyCall : String
  deriving DecidableEq, Repr

structure Output where
  confirmed : Bool
  railwayEmergencyCall : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.recorderConnected = true ∧ i.railwayEmergencyCall ≠ ""
  post := fun i o => o.confirmed = i.recorderConnected ∧
                     o.railwayEmergencyCall = i.railwayEmergencyCall

example : Spec.pre { recorderConnected := true, railwayEmergencyCall := "Emergency call details" } ∧
          Spec.post { recorderConnected := true, railwayEmergencyCall := "Emergency call details" }
                    { confirmed := true, railwayEmergencyCall := "Emergency call details" } := by
  unfold Spec; decide
