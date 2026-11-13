import ContractForge
open ContractForge

-- 2.3.1.5/S1: Systems supporting OM should provide a manual or automatic means of updating the status of case records as the case definition changes.
-- compiles: True · rejects_bad_example: True · checked: True

structure CaseRecord where
  status : String
  notes  : String
  deriving DecidableEq, Repr

structure Input where
  records : List CaseRecord
  newStatus : String
  deriving DecidableEq, Repr

structure Output where
  updatedRecords : List CaseRecord
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.records.Nodup
  post := fun i o => o.updatedRecords = i.records.map (fun cr => { cr with status := i.newStatus }) ∧
                     o.updatedRecords.length = i.records.length

example : Spec.pre { records := [{ status := "active", notes := "initial" }],
                     newStatus := "closed" } ∧
          Spec.post { records := [{ status := "active", notes := "initial" }],
                      newStatus := "closed" }
                    { updatedRecords := [{ status := "closed", notes := "initial" }] } := by
  unfold Spec; decide
