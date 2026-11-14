import ContractForge
open ContractForge

-- 2.3.1.6/S1: Systems supporting OM should track the changes made to the status of case records as a result of changes in the case definition.
-- compiles: True · rejects_bad_example: True · checked: True

structure CaseRecord where
  status : String
  deriving DecidableEq, Repr

structure Input where
  originalStatus : String
  newStatus      : String
  deriving DecidableEq, Repr

structure Output where
  originalStatus : String
  newStatus      : String
  statusChanges  : List (String × String)
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.originalStatus ≠ "" ∧ i.newStatus ≠ ""
  post := fun i o => o.originalStatus = i.originalStatus ∧
                     o.newStatus = i.newStatus ∧
                     o.statusChanges.length = 1 ∧
                     o.statusChanges.contains (i.originalStatus, i.newStatus)

example : Spec.pre { originalStatus := "open", newStatus := "closed" } ∧
          Spec.post { originalStatus := "open", newStatus := "closed" }
                    { originalStatus := "open", newStatus := "closed", statusChanges := [("open", "closed")] } := by
  unfold Spec; decide
