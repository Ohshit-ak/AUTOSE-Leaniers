import ContractForge
open ContractForge

-- 4.1.8.5: The onboard shall be capable to switch to another ETCS status when transmitted from trackside
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  currentStatus : String
  newStatus     : String
  deriving DecidableEq, Repr

structure Output where
  switched      : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.currentStatus ≠ "" ∧ i.newStatus ≠ ""
  post := fun i o => o.switched = true ↔
    (i.currentStatus = "Fitted" ∧ i.newStatus = "Unfitted") ∨
    (i.currentStatus = "Unfitted" ∧ i.newStatus = "Fitted")

example : Spec.pre { currentStatus := "Fitted", newStatus := "Unfitted" } ∧
          Spec.post { currentStatus := "Fitted", newStatus := "Unfitted" }
                    { switched := true } := by
  unfold Spec; decide
