import ContractForge
open ContractForge

-- 3.8.3/S1: The TCS shall be designed to protect its communication and data links against enemy Electronic Warfare (EW) threats, physical anti-radiation weaponry and physical destruction. [SSS366] All hardware, software, documentation, and sensitive information processed by TCS shall be physically protected, minimally at the level determined by the risk index computed in Section 3.8.1, to prevent intentional as well as unintentional disclosure, destruction, and modification. [SSS367] The TCS shall be approved for operation at the same level as the systems with which it interfaces. [SSS368]

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { approvedLevel := x.riskIndex,
    hardwareProtected := true,
    softwareProtected := true,
    docsProtected := true,
    sensitiveInfoProtected := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
