import ContractForge
open ContractForge

-- 2.1.1/I12: Based on the payment terms agreed by VSP, the field office will generate BiMonth or Monthly financial and medical report and send it to MSIU Admin team to arrange the payments for the VSP.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  reportType : String
  financialData : List String
  medicalData : List String
  deriving DecidableEq, Repr

structure Output where
  sentToMSIU : Bool
  reportType : String
  financialData : List String
  medicalData : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.reportType = "BiMonth" ∨ i.reportType = "Monthly"
  post := fun i o => o.sentToMSIU = true ∧
                     o.reportType = i.reportType ∧
                     o.financialData = i.financialData ∧
                     o.medicalData = i.medicalData

example : Spec.pre { reportType := "Monthly", financialData := ["1000", "2000"], medicalData := ["3000", "4000"] } ∧
          Spec.post { reportType := "Monthly", financialData := ["1000", "2000"], medicalData := ["3000", "4000"] }
                    { sentToMSIU := true, reportType := "Monthly", financialData := ["1000", "2000"], medicalData := ["3000", "4000"] } := by
  unfold Spec; decide
