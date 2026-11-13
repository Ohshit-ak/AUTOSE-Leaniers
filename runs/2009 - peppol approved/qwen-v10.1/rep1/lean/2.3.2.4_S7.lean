import ContractForge
open ContractForge

-- 2.3.2.4/S7: Economic operator data is data that can initially be provided by an economic operator (e.g. company registration number, VAT number, social insurance number of the company etc.) to start the VCD packaging service.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  companyRegNum : Option String
  vatNum        : Option String
  socialInsNum  : Option String
  deriving DecidableEq, Repr

structure Output where
  accepted     : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.companyRegNum.isSome ∨ i.vatNum.isSome ∨ i.socialInsNum.isSome
  post := fun i o => o.accepted = true ↔ (i.companyRegNum.isSome ∨ i.vatNum.isSome ∨ i.socialInsNum.isSome)

example : Spec.pre { companyRegNum := some "123456789", vatNum := none, socialInsNum := none } ∧
          Spec.post { companyRegNum := some "123456789", vatNum := none, socialInsNum := none }
                    { accepted := true } := by
  unfold Spec; decide
