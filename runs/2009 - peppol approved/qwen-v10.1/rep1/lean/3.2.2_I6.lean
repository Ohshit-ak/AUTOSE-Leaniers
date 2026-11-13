import ContractForge
open ContractForge

-- 3.2.2/I6: One component receives data unscheduled (Pull)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  data : String
  isScheduled : Bool
  deriving DecidableEq, Repr

structure Output where
  processed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => (o.processed = true ↔ i.isScheduled = false)

example : Spec.pre { data := "some data", isScheduled := false } ∧
          Spec.post { data := "some data", isScheduled := false } { processed := true } := by
  unfold Spec; decide
