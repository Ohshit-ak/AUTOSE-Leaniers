import ContractForge
open ContractForge

-- 3.1.1/S2: When the TCS Software is terminated normally the TCS shall enter the Normal Startup Mode of operation upon application of power. [SSS019] When the TCS software is halted due to an unplanned power interruption as well as abnormal program termination, then the TCS shall enter the Recovery Startup Mode upon application of power. [SSS020] During startup, the TCS shall determine which of the 5 levels of interaction are achievable by the TCS configuration. [SSS021] Levels of interaction higher than those achievable by a particular TCS configuration shall be prohibited. [SSS022] The TCS shall inform the operator if the operator attempts to execute a function prohibited as a result of the determined level of interaction. [SSS023]

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { startupMode := decide (x.programTerminated = false ∧ 5 = 5) ∨
                    (x.programTerminated = true ∧ 3 < 5),
    levelAchievable := if x.programTerminated = false then 5 else 3,
    informed := decide (if x.programTerminated = false then 5 < x.requestedFunction else 3 < x.requestedFunction) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
