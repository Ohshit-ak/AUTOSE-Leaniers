import ContractForge
open ContractForge

-- 2.2.4.3a/S1: Exposure investigation data to be captured must include information related to exposure levels, type of exposure (e.g., intimate, social, household, common conveyance), place of exposure, length of time the entity was exposed, frequency of exposure, and the entity's proximity to the source of exposure.
-- compiles: True · rejects_bad_example: None · checked: True

structure Exposure where
  level        : String
  type         : String
  place        : String
  timeExposed  : Nat
  frequency    : Nat
  proximity    : String
  deriving DecidableEq, Repr

structure Input where
  exposureData : List Exposure
  deriving DecidableEq, Repr

structure Output where
  validData    : List Exposure
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.exposureData.Nodup ∧
                  ∀ e ∈ i.exposureData, e.level ≠ "" ∧ e.type ≠ "" ∧ e.place ≠ "" ∧
                  0 < e.timeExposed ∧ 0 < e.frequency ∧ e.proximity ≠ ""
  post := fun i o => o.validData = i.exposureData ∧
                     ∀ e ∈ o.validData, e.level ≠ "" ∧ e.type ≠ "" ∧ e.place ≠ "" ∧
                     0 < e.timeExposed ∧ 0 < e.frequency ∧ e.proximity ≠ ""

example : Spec.pre { exposureData := [{ level := "high", type := "intimate", place := "home", timeExposed := 1, frequency := 1, proximity := "close" }, { level := "medium", type := "social", place := "work", timeExposed := 2, frequency := 2, proximity := "moderate" }] } ∧ Spec.post { exposureData := [{ level := "high", type := "intimate", place := "home", timeExposed := 1, frequency := 1, proximity := "close" }, { level := "medium", type := "social", place := "work", timeExposed := 2, frequency := 2, proximity := "moderate" }] } { validData := [{ level := "high", type := "intimate", place := "home", timeExposed := 1, frequency := 1, proximity := "close" }, { level := "medium", type := "social", place := "work", timeExposed := 2, frequency := 2, proximity := "moderate" }] } := by
  unfold Spec; decide
