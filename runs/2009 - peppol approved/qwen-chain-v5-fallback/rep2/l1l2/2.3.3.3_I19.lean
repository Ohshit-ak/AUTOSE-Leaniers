import ContractForge
open ContractForge

-- 2.3.3.3/I19: A VCD will carry a unique identifier and information about security and quality enhancing policies used by the certified VCD Service Provider when compiling the file.

-- L0 spec

structure Input where
  uniqueId      : String
  securityInfo  : String
  qualityPolicies : String
  deriving DecidableEq, Repr

structure Output where
  uniqueId      : String
  securityInfo  : String
  qualityPolicies : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.uniqueId ≠ "" ∧ i.securityInfo ≠ "" ∧ i.qualityPolicies ≠ ""
  post := fun i o => o.uniqueId = i.uniqueId ∧
                     o.securityInfo = i.securityInfo ∧
                     o.qualityPolicies = i.qualityPolicies

example : Spec.pre { uniqueId := "VCD123", securityInfo := "Secure", qualityPolicies := "QualityEnhancements" } ∧
          Spec.post { uniqueId := "VCD123", securityInfo := "Secure", qualityPolicies := "QualityEnhancements" }
                    { uniqueId := "VCD123", securityInfo := "Secure", qualityPolicies := "QualityEnhancements" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { uniqueId := x.uniqueId,
    securityInfo := x.securityInfo,
    qualityPolicies := x.qualityPolicies }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
