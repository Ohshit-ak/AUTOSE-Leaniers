import ContractForge
open ContractForge

-- 7.2.3.1: 7.2.3.1 The radio shall have an on/off switch. Switching the radio on shall initiate the following: (M) transitory lighting of any display, controls or indicator lights; automatic self-testing; if the self-test fails a visible and audible indication shall be provided; connection to a mobile network (see section 3.3); if connection is successful, the name of the network shall be displayed and an audible confirmation of successful connection shall be given; if connection is not successful, an audible and visual indication shall be provided.

-- L0 spec

structure Input where
  display : Bool
  controls : Bool
  indicatorLights : Bool
  selfTestPassed : Bool
  networkName : String
  mobileNetworkConnected : Bool
  deriving DecidableEq, Repr

structure Output where
  displayLighted : Bool
  selfTestFailed : Bool
  networkNameDisplayed : Bool
  mobileNetworkConnected : Bool
  audibleConfirmation : Bool
  audibleIndication : Bool
  visualIndication : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.display ∨ i.controls ∨ i.indicatorLights
  post := fun i o =>
    (o.displayLighted = true ↔ i.display ∨ i.controls ∨ i.indicatorLights) ∧
    (o.selfTestFailed = true ↔ ¬i.selfTestPassed) ∧
    (o.networkNameDisplayed = true ↔ i.mobileNetworkConnected) ∧
    (o.mobileNetworkConnected = true ↔ i.mobileNetworkConnected) ∧
    (o.audibleConfirmation = true ↔ i.mobileNetworkConnected) ∧
    (o.audibleIndication = true ↔ ¬i.mobileNetworkConnected) ∧
    (o.visualIndication = true ↔ ¬i.mobileNetworkConnected)

example : Spec.pre { display := true, controls := false, indicatorLights := false,
                     selfTestPassed := false, networkName := "NetworkX", mobileNetworkConnected := false } ∧
          Spec.post { display := true, controls := false, indicatorLights := false,
                      selfTestPassed := false, networkName := "NetworkX", mobileNetworkConnected := false }
                    { displayLighted := true, selfTestFailed := true, networkNameDisplayed := false,
                      mobileNetworkConnected := false, audibleConfirmation := false, audibleIndication := true,
                      visualIndication := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { displayLighted := decide (x.display ∨ x.controls ∨ x.indicatorLights),
    selfTestFailed := decide (¬x.selfTestPassed),
    networkNameDisplayed := decide (x.mobileNetworkConnected),
    mobileNetworkConnected := decide (x.mobileNetworkConnected),
    audibleConfirmation := decide (x.mobileNetworkConnected),
    audibleIndication := decide (¬x.mobileNetworkConnected),
    visualIndication := decide (¬x.mobileNetworkConnected) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
