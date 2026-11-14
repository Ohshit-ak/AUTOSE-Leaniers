import ContractForge
open ContractForge

-- 3.2.2/S2: While flying two MAE AVs Beyond Line Of Sight (BLOS), the TCS shall provide full control functionality of each AV. [SSS108] AV specific components used to perform ground based closed loop command and control functions for TCS shall be initialized upon operator selection of a specific AV. [SSS109] The TCS shall transmit command and control information to the AV via the uplink to the AV [SSS110], and receive AV telemetry and payload information via downlink from the AV [SSS111].

-- L0 spec

structure Input where
  av1Selected : Bool
  av2Selected : Bool
  telemetry  : List String
  payload    : List String
  deriving DecidableEq, Repr

structure Output where
  av1Control : Bool
  av2Control : Bool
  telemetryReceived : Bool
  payloadReceived : Bool
  deriving DecidableEq, Repr

-- IMPL: TCS initializes specific components for the selected AV and transmits/receives data via uplink/downlink.

def Spec : Contract Input Output where
  pre  := fun i => i.av1Selected ∨ i.av2Selected
  post := fun i o => (o.av1Control = true ↔ i.av1Selected) ∧
                     (o.av2Control = true ↔ i.av2Selected) ∧
                     (o.telemetryReceived = true ↔ i.telemetry.Nodup) ∧
                     (o.payloadReceived = true ↔ i.payload.Nodup)

example : Spec.pre { av1Selected := true, av2Selected := false, telemetry := ["t1", "t2"], payload := ["p1"] } ∧
          Spec.post { av1Selected := true, av2Selected := false, telemetry := ["t1", "t2"], payload := ["p1"] }
                    { av1Control := true, av2Control := false, telemetryReceived := true, payloadReceived := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { av1Control := decide (x.av1Selected),
    av2Control := decide (x.av2Selected),
    telemetryReceived := decide (x.telemetry.Nodup),
    payloadReceived := decide (x.payload.Nodup) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
