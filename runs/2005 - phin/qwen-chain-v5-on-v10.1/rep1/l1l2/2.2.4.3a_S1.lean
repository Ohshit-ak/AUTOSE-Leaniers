import ContractForge
open ContractForge

-- 2.2.4.3a/S1: Exposure investigation data to be captured must include information related to exposure levels, type of exposure (e.g., intimate, social, household, common conveyance), place of exposure, length of time the entity was exposed, frequency of exposure, and the entity's proximity to the source of exposure.

-- L0 spec

structure Exposure where
  level        : String
  type         : String
  place        : String
  time         : Nat
  frequency    : Nat
  proximity    : Nat
  deriving DecidableEq, Repr

structure Input where
  exposures : List Exposure
  deriving DecidableEq, Repr

structure Output where
  valid      : Bool
  exposures  : List Exposure
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.exposures.Nodup
  post := fun i o => o.valid = true ↔
    o.exposures.length = i.exposures.length ∧
    ∀ e ∈ i.exposures, o.exposures.contains e ∧
    e.level ≠ "" ∧
    e.type ∈ ["intimate", "social", "household", "common conveyance"] ∧
    e.place ≠ "" ∧
    0 < e.time ∧
    0 < e.frequency ∧
    0 < e.proximity

example : Spec.pre { exposures := [{ level := "high", type := "intimate", place := "home", time := 5, frequency := 1, proximity := 1 }] } ∧
          Spec.post { exposures := [{ level := "high", type := "intimate", place := "home", time := 5, frequency := 1, proximity := 1 }] }
                    { valid := true, exposures := [{ level := "high", type := "intimate", place := "home", time := 5, frequency := 1, proximity := 1 }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { valid := x.exposures.Nodup ∧
        x.exposures.length = x.exposures.length ∧
        ∀ e ∈ x.exposures, x.exposures.contains e ∧
        e.level ≠ "" ∧
        e.type ∈ ["intimate", "social", "household", "common conveyance"] ∧
        e.place ≠ "" ∧
        0 < e.time ∧
        0 < e.frequency ∧
        0 < e.proximity,
    exposures := x.exposures }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
