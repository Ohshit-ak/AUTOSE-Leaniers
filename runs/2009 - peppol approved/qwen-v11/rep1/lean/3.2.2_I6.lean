import ContractForge
open ContractForge

-- 3.2.2/I6: One component receives data unscheduled (Pull)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  data : String
  immediateProcessing : Bool
  deriving DecidableEq, Repr

structure Output where
  processed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => (o.processed = true ↔ i.immediateProcessing = false)

example : Spec.pre { data := "someData", immediateProcessing := false } ∧
          Spec.post { data := "someData", immediateProcessing := false }
                    { processed := true } := by
  unfold Spec; decide
