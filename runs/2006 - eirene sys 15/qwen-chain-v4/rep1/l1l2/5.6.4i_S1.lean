import ContractForge
open ContractForge

-- 5.6.4i/S1: If directed network selection is implemented and voice calls are ongoing at the time when the external device attempts to trigger a network change, an audible and visual indication shall be given to the driver and network change shall be deferred until the call is terminated or until coverage of the current network is lost.

-- L0 spec

structure Input where
  directedNetworkSelection : Bool
  ongoingVoiceCalls : Bool
  deriving DecidableEq, Repr

structure Output where
  audibleIndication : Bool
  visualIndication : Bool
  networkChangeDeferred : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.directedNetworkSelection = true ∧ i.ongoingVoiceCalls = true
  post := fun i o => (o.audibleIndication = true ∧ o.visualIndication = true ∧
                      o.networkChangeDeferred = true ↔
                      i.directedNetworkSelection = true ∧ i.ongoingVoiceCalls = true) ∧
                     (o.audibleIndication = false → i.ongoingVoiceCalls = false) ∧
                     (o.visualIndication = false → i.ongoingVoiceCalls = false) ∧
                     (o.networkChangeDeferred = false → i.ongoingVoiceCalls = false)

example : Spec.pre { directedNetworkSelection := true, ongoingVoiceCalls := true } ∧
          Spec.post { directedNetworkSelection := true, ongoingVoiceCalls := true }
                    { audibleIndication := true, visualIndication := true, networkChangeDeferred := true } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  audibleIndication : Bool
  visualIndication : Bool
  networkChangeDeferred : Bool
  deriving DecidableEq, Repr

def ComputeIndicationsContract : Contract Input Mid where
  pre  := fun i => i.directedNetworkSelection = true ∧ i.ongoingVoiceCalls = true
  post := fun i m => (m.audibleIndication = true ∧ m.visualIndication = true ∧
                      m.networkChangeDeferred = true ↔
                      i.directedNetworkSelection = true ∧ i.ongoingVoiceCalls = true)

def ApplyIndicationsContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.audibleIndication = m.audibleIndication) ∧
                     (o.visualIndication = m.visualIndication) ∧
                     (o.networkChangeDeferred = m.networkChangeDeferred) ∧
                     (o.audibleIndication = false → m.audibleIndication = false) ∧
                     (o.visualIndication = false → m.visualIndication = false) ∧
                     (o.networkChangeDeferred = false → m.networkChangeDeferred = false)
