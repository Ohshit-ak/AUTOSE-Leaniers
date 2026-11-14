import ContractForge
open ContractForge

-- 3.1.1/S2: When the TCS Software is terminated normally the TCS shall enter the Normal Startup Mode of operation upon application of power. [SSS019] When the TCS software is halted due to an unplanned power interruption as well as abnormal program termination, then the TCS shall enter the Recovery Startup Mode upon application of power. [SSS020] During startup, the TCS shall determine which of the 5 levels of interaction are achievable by the TCS configuration. [SSS021] Levels of interaction higher than those achievable by a particular TCS configuration shall be prohibited. [SSS022] The TCS shall inform the operator if the operator attempts to execute a function prohibited as a result of the determined level of interaction. [SSS023]

-- L0 spec

structure Input where
  powerApplied : Bool
  configLevel  : Nat -- Level of interaction achievable by the TCS configuration
  functionRequested : Nat -- Level of interaction requested by the operator
  deriving DecidableEq, Repr

structure Output where
  startupMode : String
  informed    : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.powerApplied
  post := fun i o => (o.startupMode = "Normal" ↔ i.powerApplied ∧ i.configLevel ≥ 1) ∧
                     (o.startupMode = "Recovery" ↔ i.powerApplied ∧ i.configLevel = 0) ∧
                     (o.informed = true ↔ o.startupMode = "Recovery" ∧ i.functionRequested > i.configLevel)

example : Spec.pre { powerApplied := true, configLevel := 3, functionRequested := 2 } ∧
          Spec.post { powerApplied := true, configLevel := 3, functionRequested := 2 }
                    { startupMode := "Normal", informed := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { startupMode := if x.powerApplied ∧ x.configLevel ≥ 1 then "Normal" else if x.powerApplied ∧ x.configLevel = 0 then "Recovery" else "Normal",
    informed := (x.powerApplied ∧ x.configLevel = 0 ∧ x.functionRequested > x.configLevel) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
