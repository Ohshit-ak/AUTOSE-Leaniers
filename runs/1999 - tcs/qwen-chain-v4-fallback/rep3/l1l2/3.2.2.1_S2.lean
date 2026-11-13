import ContractForge
open ContractForge

-- 3.2.2.1/S2: The TCS shall provide the capability to control the AV flight commands as well as to release the AV to an autonomous flight control mode. [SSS118] AV telemetry data shall be available to support other TCS functions as required. [SSS119] The TCS shall provide the capability to control the flight of the selected AV in accordance with the specific AV's operational performance capabilities. [SSS120] The TCS shall provide the capability to fully control and display the AV's Identification Friend or Foe (IFF). [SSS121] The TCS shall provide the capability to enter AV preset limits which, as a minimum, will include airspeed limits, altitude limits, and fuel limits. [SSS122]

-- L0 spec

structure Input where
  avFlightCommands : List String
  avTelemetryData  : List String
  avIdentification : String
  presetLimits     : List String
  deriving DecidableEq, Repr

structure Output where
  avFlightMode     : Bool
  avTelemetryMode  : Bool
  avIffMode        : Bool
  avPresetLimits   : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.avTelemetryData.Nodup ∧ i.avIdentification ≠ ""
  post := fun i o => (o.avFlightMode = true ↔ i.avFlightCommands.Nodup) ∧
                     (o.avTelemetryMode = true ↔ i.avTelemetryData.Nodup) ∧
                     (o.avIffMode = true ↔ i.avIdentification ≠ "") ∧
                     (o.avPresetLimits = i.presetLimits)

example : Spec.pre { avFlightCommands := ["cmd1", "cmd2"], avTelemetryData := ["data1", "data2"], avIdentification := "AV123", presetLimits := ["100", "2000", "500"] } ∧
          Spec.post { avFlightCommands := ["cmd1", "cmd2"], avTelemetryData := ["data1", "data2"], avIdentification := "AV123", presetLimits := ["100", "2000", "500"] }
                     { avFlightMode := true, avTelemetryMode := true, avIffMode := true, avPresetLimits := ["100", "2000", "500"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { avFlightMode := x.avFlightCommands.Nodup,
    avTelemetryMode := x.avTelemetryData.Nodup,
    avIffMode := x.avIdentification ≠ "",
    avPresetLimits := x.presetLimits }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
