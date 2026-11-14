import ContractForge
open ContractForge

-- 3.2.2/I5: One component sends data unscheduled to another one (Push)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  data : String
  deriving DecidableEq, Repr

structure Output where
  received : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.received ↔ false

example : Spec.pre { data := "some data" } ∧ Spec.post { data := "some data" } { received := false } := by
  unfold Spec; decide
