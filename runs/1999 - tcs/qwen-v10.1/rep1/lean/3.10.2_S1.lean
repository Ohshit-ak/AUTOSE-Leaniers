import ContractForge
open ContractForge

-- 3.10.2/S1: The TCS throughput shall not exceed 50% of the throughput capability delivered over any 10 second period [SSS389], and as an objective throughput shall not exceed 25% of throughput capability delivered over any 10 second period. [SSS390].
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros ≤ 10000000

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 9000000 } := by
  unfold Spec; decide
