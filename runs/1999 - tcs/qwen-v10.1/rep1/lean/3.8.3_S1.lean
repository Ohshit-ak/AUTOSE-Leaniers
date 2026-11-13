import ContractForge
open ContractForge

-- 3.8.3/S1: The TCS shall be designed to protect its communication and data links against enemy Electronic Warfare (EW) threats, physical anti-radiation weaponry and physical destruction. [SSS366] All hardware, software, documentation, and sensitive information processed by TCS shall be physically protected, minimally at the level determined by the risk index computed in Section 3.8.1, to prevent intentional as well as unintentional disclosure, destruction, and modification. [SSS367] The TCS shall be approved for operation at the same level as the systems with which it interfaces. [SSS368]
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  riskIndex : Nat
  hardware  : String
  software  : String
  docs     : String
  sensitiveInfo : String
  deriving DecidableEq, Repr

structure Output where
  approvedLevel : Nat
  hardwareProtected : Bool
  softwareProtected : Bool
  docsProtected : Bool
  sensitiveInfoProtected : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.riskIndex > 0
  post := fun i o => o.approvedLevel = i.riskIndex ∧
                     o.hardwareProtected = true ∧
                     o.softwareProtected = true ∧
                     o.docsProtected = true ∧
                     o.sensitiveInfoProtected = true

example : Spec.pre { riskIndex := 5, hardware := "TCS hardware", software := "TCS software", docs := "TCS documentation", sensitiveInfo := "TCS sensitive information" } ∧
          Spec.post { riskIndex := 5, hardware := "TCS hardware", software := "TCS software", docs := "TCS documentation", sensitiveInfo := "TCS sensitive information" }
                    { approvedLevel := 5, hardwareProtected := true, softwareProtected := true, docsProtected := true, sensitiveInfoProtected := true } := by
  unfold Spec; decide
