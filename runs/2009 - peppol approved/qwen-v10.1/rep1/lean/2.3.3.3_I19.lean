import ContractForge
open ContractForge

-- 2.3.3.3/I19: A VCD will carry a unique identifier and information about security and quality enhancing policies used by the certified VCD Service Provider when compiling the file.
-- compiles: True · rejects_bad_example: None · checked: True

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
