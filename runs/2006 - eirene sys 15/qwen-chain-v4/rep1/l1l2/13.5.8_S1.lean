import ContractForge
open ContractForge

-- 13.5.8/S1: In the case of Cab radio, details of the confirmation shall be passed to the train borne recorder if a train borne recorder is connected to the Cab radio.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { trainBorneRecorderConnected := x.cabRadio.trainBorneRecorderConnected,
    confirmationDetails := if x.cabRadio.trainBorneRecorderConnected then some x.confirmation.details else none }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
