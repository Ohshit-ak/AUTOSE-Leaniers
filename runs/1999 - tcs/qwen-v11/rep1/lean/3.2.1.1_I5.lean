import ContractForge
open ContractForge

-- 3.2.1.1/I5: Payload search area information such as: visual acuity range due to atmospheric conditions, diurnal transition periods for thermal imagery, and lunar and solar terrain shadowing. [SSS086]
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  visualAcuityRange : String
  diurnalTransition  : String
  lunarShadowing     : String
  solarShadowing     : String
  deriving DecidableEq, Repr

structure Output where
  visualAcuityRangeInfo : String
  diurnalTransitionInfo : String
  lunarShadowingInfo    : String
  solarShadowingInfo    : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.visualAcuityRange ≠ "" ∧
                   i.diurnalTransition ≠ "" ∧
                   i.lunarShadowing ≠ "" ∧
                   i.solarShadowing ≠ ""
  post := fun i o => o.visualAcuityRangeInfo = i.visualAcuityRange ∧
                     o.diurnalTransitionInfo = i.diurnalTransition ∧
                     o.lunarShadowingInfo = i.lunarShadowing ∧
                     o.solarShadowingInfo = i.solarShadowing

example : Spec.pre { visualAcuityRange := "10-20", diurnalTransition := "6-18", lunarShadowing := "1-24", solarShadowing := "1-12" } ∧
          Spec.post { visualAcuityRange := "10-20", diurnalTransition := "6-18", lunarShadowing := "1-24", solarShadowing := "1-12" }
                    { visualAcuityRangeInfo := "10-20", diurnalTransitionInfo := "6-18", lunarShadowingInfo := "1-24", solarShadowingInfo := "1-12" } := by
  unfold Spec; decide
