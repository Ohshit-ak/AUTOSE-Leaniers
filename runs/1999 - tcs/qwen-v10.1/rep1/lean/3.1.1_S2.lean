import ContractForge
open ContractForge

-- 3.1.1/S2: When the TCS Software is terminated normally the TCS shall enter the Normal Startup Mode of operation upon application of power. [SSS019] When the TCS software is halted due to an unplanned power interruption as well as abnormal program termination, then the TCS shall enter the Recovery Startup Mode upon application of power. [SSS020] During startup, the TCS shall determine which of the 5 levels of interaction are achievable by the TCS configuration. [SSS021] Levels of interaction higher than those achievable by a particular TCS configuration shall be prohibited. [SSS022] The TCS shall inform the operator if the operator attempts to execute a function prohibited as a result of the determined level of interaction. [SSS023]
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  powerApplied : Bool
  programTerminated : Bool
  configLevels : List Nat
  requestedFunction : Nat
  deriving DecidableEq, Repr

structure Output where
  startupMode : Bool
  levelAchievable : Nat
  informed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.powerApplied = true
  post := fun i o => (o.startupMode = true ↔
    (i.programTerminated = false ∧ o.levelAchievable = 5) ∨
    (i.programTerminated = true ∧ o.levelAchievable < 5) ∧
    (o.informed = true ↔ o.levelAchievable < i.requestedFunction))

example : Spec.pre { powerApplied := true, programTerminated := false,
                     configLevels := [1, 2, 3, 4, 5], requestedFunction := 3 } ∧
          Spec.post { powerApplied := true, programTerminated := false,
                      configLevels := [1, 2, 3, 4, 5], requestedFunction := 3 }
                    { startupMode := true, levelAchievable := 5, informed := false } := by
  unfold Spec; decide

example : Spec.pre { powerApplied := true, programTerminated := true,
                     configLevels := [1, 2, 3], requestedFunction := 4 } ∧
          Spec.post { powerApplied := true, programTerminated := true,
                      configLevels := [1, 2, 3], requestedFunction := 4 }
                    { startupMode := true, levelAchievable := 3, informed := true } := by
  unfold Spec; decide
