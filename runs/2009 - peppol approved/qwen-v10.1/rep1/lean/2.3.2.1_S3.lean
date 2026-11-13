import ContractForge
open ContractForge

-- 2.3.2.1/S3: Sensitive economic operator data must initially be provided by an economic operator (e.g. company registration number, VAT number, social insurance number of the company etc.) in order to create an account and to start any VCD packaging service.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  companyRegistrationNumber : String
  vatNumber                 : String
  socialInsuranceNumber     : String
  deriving DecidableEq, Repr

structure Output where
  accountCreated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.companyRegistrationNumber ≠ "" ∧
                  i.vatNumber ≠ "" ∧
                  i.socialInsuranceNumber ≠ ""
  post := fun i o => o.accountCreated = true ↔
    (i.companyRegistrationNumber ≠ "" ∧
     i.vatNumber ≠ "" ∧
     i.socialInsuranceNumber ≠ "")

example : Spec.pre { companyRegistrationNumber := "123456789", vatNumber := "DE123456789", socialInsuranceNumber := "SI123456789" } ∧
          Spec.post { companyRegistrationNumber := "123456789", vatNumber := "DE123456789", socialInsuranceNumber := "SI123456789" }
                    { accountCreated := true } := by
  unfold Spec; decide
