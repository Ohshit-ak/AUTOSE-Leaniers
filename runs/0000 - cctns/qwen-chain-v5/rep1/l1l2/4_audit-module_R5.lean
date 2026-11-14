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

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { exportedRecords := x.cases.map (fun ac => { timestamp := 0, caseId := ac.caseId, event := "" }),
    remainingRecords := [] }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
