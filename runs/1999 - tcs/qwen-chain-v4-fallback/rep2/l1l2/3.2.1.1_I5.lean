import ContractForge
open ContractForge

-- 3.2.1.1/I5: Payload search area information such as: visual acuity range due to atmospheric conditions, diurnal transition periods for thermal imagery, and lunar and solar terrain shadowing. [SSS086]

-- L0 spec

structure Input where
  visualAcuityRange : String
  diurnalTransitionPeriods : List String
  lunarSolarShadowing : List String
  deriving DecidableEq, Repr

structure Output where
  visualAcuityRangeInfo : String
  diurnalTransitionPeriodsInfo : List String
  lunarSolarShadowingInfo : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.visualAcuityRange ≠ "" ∧ i.diurnalTransitionPeriods.Nodup ∧ i.lunarSolarShadowing.Nodup
  post := fun i o => o.visualAcuityRangeInfo = i.visualAcuityRange ∧
                     o.diurnalTransitionPeriodsInfo = i.diurnalTransitionPeriods ∧
                     o.lunarSolarShadowingInfo = i.lunarSolarShadowing

example : Spec.pre { visualAcuityRange := "10-20", diurnalTransitionPeriods := ["06:00-09:00", "17:00-20:00"], lunarSolarShadowing := ["08:00-10:00", "14:00-16:00"] } ∧
          Spec.post { visualAcuityRange := "10-20", diurnalTransitionPeriods := ["06:00-09:00", "17:00-20:00"], lunarSolarShadowing := ["08:00-10:00", "14:00-16:00"] }
                    { visualAcuityRangeInfo := "10-20", diurnalTransitionPeriodsInfo := ["06:00-09:00", "17:00-20:00"], lunarSolarShadowingInfo := ["08:00-10:00", "14:00-16:00"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { visualAcuityRangeInfo := x.visualAcuityRange,
    diurnalTransitionPeriodsInfo := x.diurnalTransitionPeriods,
    lunarSolarShadowingInfo := x.lunarSolarShadowing }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
