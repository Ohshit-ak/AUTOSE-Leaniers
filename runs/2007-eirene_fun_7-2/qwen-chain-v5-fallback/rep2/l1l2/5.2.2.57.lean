import ContractForge
open ContractForge

-- 5.2.2.57: 5.2.2.57 If a train-borne recorder is connected to the Cab radio, details of an incoming Railway emergency call shall be transmitted to the train-borne recorder for recording, see section 5.8. (M) Confirm receipt of Railway emergency call

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { confirmed := x.recorderConnected,
    railwayEmergencyCall := x.railwayEmergencyCall }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
