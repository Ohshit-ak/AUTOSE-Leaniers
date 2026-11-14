import ContractForge
open ContractForge

-- 5.2.3.25iii: 5.2.3.25iii If directed network selection is implemented and voice calls are ongoing at the time when the external device attempts to trigger a network change, an audible and visual indication shall be given to the driver and network change shall be deferred until the call is terminated or until coverage of the current network is lost. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  directedNetworkSelection : Bool
  ongoingVoiceCalls         : Bool
  deriving DecidableEq, Repr

structure Output where
  audibleIndication         : Bool
  visualIndication          : Bool
  networkChangeDeferred     : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.directedNetworkSelection = true
  post := fun i o => (o.audibleIndication = true ∧ o.visualIndication = true ∧ o.networkChangeDeferred = true) ↔
                     (i.ongoingVoiceCalls = true)

example : Spec.pre { directedNetworkSelection := true, ongoingVoiceCalls := true } ∧
          Spec.post { directedNetworkSelection := true, ongoingVoiceCalls := true }
                    { audibleIndication := true, visualIndication := true, networkChangeDeferred := true } := by
  unfold Spec; decide
