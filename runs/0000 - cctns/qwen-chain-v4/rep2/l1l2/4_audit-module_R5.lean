import ContractForge
open ContractForge

-- 4/audit-module/R5: The System must be able to export audit trails for specified cases (without affecting the audit trail stored by the System). This functionality can be used by external auditors who wish to examine or analyse system activity.

-- L0 spec

structure AuditCase where
  caseId : Nat
  description : String
  deriving DecidableEq, Repr

structure AuditRecord where
  timestamp : Nat
  caseId : Nat
  action : String
  details : String
  deriving DecidableEq, Repr

structure Input where
  caseIds : List Nat
  auditRecords : List AuditRecord
  deriving DecidableEq, Repr

structure Output where
  exportedRecords : List AuditRecord
  remainingRecords : List AuditRecord
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.caseIds.Nodup
  post := fun i o => 
    o.exportedRecords.length = i.caseIds.length ∧
    o.exportedRecords.all (fun r => ∃ c ∈ i.caseIds, r.caseId = c) ∧
    o.remainingRecords.length = i.auditRecords.length - o.exportedRecords.length ∧
    (o.exportedRecords ++ o.remainingRecords).length = i.auditRecords.length ∧
    (o.exportedRecords ++ o.remainingRecords).Nodup ∧
    ∀ r ∈ o.exportedRecords, ∃ c ∈ i.caseIds, r.caseId = c ∧
    ∀ r ∈ o.remainingRecords, ¬(∃ c ∈ i.caseIds, r.caseId = c)

example : Spec.pre { caseIds := [1, 3], auditRecords := [{ timestamp := 100, caseId := 1, action := "log in", details := "user1" },
                                                           { timestamp := 101, caseId := 2, action := "log out", details := "user1" },
                                                           { timestamp := 102, caseId := 3, action := "log in", details := "user2" }] } ∧
          Spec.post { caseIds := [1, 3], auditRecords := [{ timestamp := 100, caseId := 1, action := "log in", details := "user1" },
                                                           { timestamp := 101, caseId := 2, action := "log out", details := "user1" },
                                                           { timestamp := 102, caseId := 3, action := "log in", details := "user2" }] }
                    { exportedRecords := [{ timestamp := 100, caseId := 1, action := "log in", details := "user1" },
                                          { timestamp := 102, caseId := 3, action := "log in", details := "user2" }],
                      remainingRecords := [{ timestamp := 101, caseId := 2, action := "log out", details := "user1" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  exportedRecords : List AuditRecord
  remainingRecords : List AuditRecord
  deriving DecidableEq, Repr

def ExportRecordsContract : Contract Input Mid where
  pre  := fun i => i.caseIds.Nodup
  post := fun i m => 
    m.exportedRecords.length = i.caseIds.length ∧
    m.exportedRecords.all (fun r => ∃ c ∈ i.caseIds, r.caseId = c) ∧
    m.remainingRecords.length = i.auditRecords.length - m.exportedRecords.length ∧
    (m.exportedRecords ++ m.remainingRecords).length = i.auditRecords.length ∧
    (m.exportedRecords ++ m.remainingRecords).Nodup ∧
    ∀ r ∈ m.exportedRecords, ∃ c ∈ i.caseIds, r.caseId = c ∧
    ∀ r ∈ m.remainingRecords, ¬(∃ c ∈ i.caseIds, r.caseId = c)

def ProcessRecordsContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => 
    o.exportedRecords = m.exportedRecords ∧
    o.remainingRecords = m.remainingRecords
