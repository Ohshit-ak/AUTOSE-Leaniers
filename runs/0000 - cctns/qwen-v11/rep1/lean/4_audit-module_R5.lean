import ContractForge
open ContractForge

-- 4/audit-module/R5: The System must be able to export audit trails for specified cases (without affecting the audit trail stored by the System). This functionality can be used by external auditors who wish to examine or analyse system activity.
-- compiles: True · rejects_bad_example: None · checked: True

structure AuditCase where
  caseId : Nat
  description : String
  deriving DecidableEq, Repr

structure AuditRecord where
  timestamp : Nat
  caseId : Nat
  event : String
  deriving DecidableEq, Repr

structure Input where
  cases : List AuditCase
  deriving DecidableEq, Repr

structure Output where
  exportedRecords : List AuditRecord
  remainingRecords : List AuditRecord
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cases.Nodup
  post := fun i o => 
    o.exportedRecords.length + o.remainingRecords.length = i.cases.length ∧
    ∀ cr ∈ o.exportedRecords, ∃ ac ∈ i.cases, cr.caseId = ac.caseId ∧
    (o.exportedRecords = [] ↔ o.remainingRecords = i.cases.map (fun ac => { timestamp := 0, caseId := ac.caseId, event := "" })) ∧
    (o.remainingRecords = [] ↔ o.exportedRecords = i.cases.map (fun ac => { timestamp := 0, caseId := ac.caseId, event := "" }))

example : Spec.pre { cases := [{ caseId := 1, description := "Case 1" }, { caseId := 2, description := "Case 2" }] } ∧
          Spec.post { cases := [{ caseId := 1, description := "Case 1" }, { caseId := 2, description := "Case 2" }] }
                    { exportedRecords := [], remainingRecords := [{ timestamp := 0, caseId := 1, event := "" }, { timestamp := 0, caseId := 2, event := "" }] } := by
  unfold Spec; decide
