import ContractForge
open ContractForge

-- 7.2.3.1: 7.2.3.1 The radio shall have an on/off switch. Switching the radio on shall initiate the following: (M) transitory lighting of any display, controls or indicator lights; automatic self-testing; if the self-test fails a visible and audible indication shall be provided; connection to a mobile network (see section 3.3); if connection is successful, the name of the network shall be displayed and an audible confirmation of successful connection shall be given; if connection is not successful, an audible and visual indication shall be provided.
-- compiles: True · rejects_bad_example: True · checked: True

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
