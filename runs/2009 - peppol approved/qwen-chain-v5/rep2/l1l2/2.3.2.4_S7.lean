import ContractForge
open ContractForge

-- 2.3.2.4/S7: Economic operator data is data that can initially be provided by an economic operator (e.g. company registration number, VAT number, social insurance number of the company etc.) to start the VCD packaging service.

-- L0 spec

structure Input where
  companyRegNum : String
  vatNum        : String
  socialInsNum  : String
  deriving DecidableEq, Repr

structure Output where
  accepted     : Bool
  message      : String
  companyRegNum : String
  vatNum        : String
  socialInsNum  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.companyRegNum ≠ "" ∨ i.vatNum ≠ "" ∨ i.socialInsNum ≠ ""
  post := fun i o => (o.accepted = true ↔
    (i.companyRegNum ≠ "" ∨ i.vatNum ≠ "" ∨ i.socialInsNum ≠ "")) ∧
    (o.accepted = false → o.message = "No valid economic operator data provided.") ∧
    (o.accepted = true → o.message = "Economic operator data accepted.") ∧
    (o.accepted = true → o.companyRegNum = i.companyRegNum) ∧
    (o.accepted = true → o.vatNum = i.vatNum) ∧
    (o.accepted = true → o.socialInsNum = i.socialInsNum)

example : Spec.pre { companyRegNum := "123456789", vatNum := "", socialInsNum := "" } ∧
          Spec.post { companyRegNum := "123456789", vatNum := "", socialInsNum := "" }
                    { accepted := true, message := "Economic operator data accepted.", companyRegNum := "123456789", vatNum := "", socialInsNum := "" } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { accepted := decide ((x.companyRegNum ≠ "" ∨ x.vatNum ≠ "" ∨ x.socialInsNum ≠ "")),
    message := if (x.companyRegNum ≠ "" ∨ x.vatNum ≠ "" ∨ x.socialInsNum ≠ "") then
      "Economic operator data accepted."
    else
      "No valid economic operator data provided.",
    companyRegNum := if (x.companyRegNum ≠ "" ∨ x.vatNum ≠ "" ∨ x.socialInsNum ≠ "") then
      x.companyRegNum
    else
      "",
    vatNum := if (x.companyRegNum ≠ "" ∨ x.vatNum ≠ "" ∨ x.socialInsNum ≠ "") then
      x.vatNum
    else
      "",
    socialInsNum := if (x.companyRegNum ≠ "" ∨ x.vatNum ≠ "" ∨ x.socialInsNum ≠ "") then
      x.socialInsNum
    else
      "" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
