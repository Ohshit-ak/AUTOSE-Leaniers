import ContractForge
open ContractForge

-- 2.3.2.4/S7: Economic operator data is data that can initially be provided by an economic operator (e.g. company registration number, VAT number, social insurance number of the company etc.) to start the VCD packaging service.
-- compiles: True · rejects_bad_example: None · checked: True

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
