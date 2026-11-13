import ContractForge
open ContractForge

-- 12.3.2: 12.3.2 The transfer time for each message segment should be less then 30 seconds for 95% of messages. (O)
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros ≤ 30000000

example : Spec.pre { } ∧ Spec.post { } { elapsedMicros := 28000000 } := by
  unfold Spec; decide
