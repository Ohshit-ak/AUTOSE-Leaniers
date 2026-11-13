import ContractForge
open ContractForge

-- 2.3.1.6/S1: Systems supporting OM should track the changes made to the status of case records as a result of changes in the case definition.
-- compiles: False · rejects_bad_example: None · checked: False

structure CaseRecord where
  status : String
  deriving DecidableEq, Repr

structure Input where
  statusHistory : List CaseRecord
  deriving DecidableEq, Repr

structure Output where
  statusHistory : List CaseRecord
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.statusHistory.Nodup
  post := fun i o => o.statusHistory = i.statusHistory ∧
                     (o.statusHistory.length = i.statusHistory.length ∧
                      ∀ j ∈ o.statusHistory, j.status = i.statusHistory.last.j.status)

example : Spec.pre { statusHistory := [{ status := "open" }, { status := "closed" }] } ∧
          Spec.post { statusHistory := [{ status := "open" }, { status := "closed" }] }
                    { statusHistory := [{ status := "open" }, { status := "closed" }] } := by
  unfold Spec; decide
