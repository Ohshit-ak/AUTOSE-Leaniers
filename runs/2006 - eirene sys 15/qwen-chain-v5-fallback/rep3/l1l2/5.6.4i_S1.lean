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
  post := fun i o => (o.audibleIndication = true ↔ i.directedNetworkSelection = true) ∧
                     (o.visualIndication = true ↔ i.directedNetworkSelection = true) ∧
                     (o.networkChangeDeferred = true ↔
                      (i.directedNetworkSelection = true ∧ i.ongoingVoiceCalls = true))

example : Spec.pre { directedNetworkSelection := true, ongoingVoiceCalls := true } ∧
          Spec.post { directedNetworkSelection := true, ongoingVoiceCalls := true }
                    { audibleIndication := true, visualIndication := true, networkChangeDeferred := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { audibleIndication := decide (x.directedNetworkSelection = true),
    visualIndication := decide (x.directedNetworkSelection = true),
    networkChangeDeferred := decide ((x.directedNetworkSelection = true ∧ x.ongoingVoiceCalls = true)) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
