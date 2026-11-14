import ContractForge
open ContractForge

-- 13.5.8/S1: In the case of Cab radio, details of the confirmation shall be passed to the train borne recorder if a train borne recorder is connected to the Cab radio.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { trainBorneRecorderConnected := decide (x.trainBorneRecorderConnected = true),
    confirmationDetails := if x.trainBorneRecorderConnected = true then x.confirmationDetails else x.confirmationDetails }
