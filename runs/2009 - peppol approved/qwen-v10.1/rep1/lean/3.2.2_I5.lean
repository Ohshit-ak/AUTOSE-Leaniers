import ContractForge
open ContractForge

-- 3.2.2/I5: One component sends data unscheduled to another one (Push)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  data : String
  isScheduled : Bool
  deriving DecidableEq, Repr

structure Output where
  received : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.received ↔ i.isScheduled = false

example : Spec.pre { data := "unscheduledData", isScheduled := false } ∧ Spec.post { data := "unscheduledData", isScheduled := false } { received := true } := by
  unfold Spec; decide
