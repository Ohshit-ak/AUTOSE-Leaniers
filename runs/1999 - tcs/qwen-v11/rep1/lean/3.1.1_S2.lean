import ContractForge
open ContractForge

-- 3.1.1/S2: When the TCS Software is terminated normally the TCS shall enter the Normal Startup Mode of operation upon application of power. [SSS019] When the TCS software is halted due to an unplanned power interruption as well as abnormal program termination, then the TCS shall enter the Recovery Startup Mode upon application of power. [SSS020] During startup, the TCS shall determine which of the 5 levels of interaction are achievable by the TCS configuration. [SSS021] Levels of interaction higher than those achievable by a particular TCS configuration shall be prohibited. [SSS022] The TCS shall inform the operator if the operator attempts to execute a function prohibited as a result of the determined level of interaction. [SSS023]
-- compiles: True · rejects_bad_example: True · checked: True

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
