import ContractForge
open ContractForge

-- 3.3.4/S1: There is a quality of service requirement for handover executions (eg a break of 10s would clearly be unacceptable to the user). 300ms represents our current best estimate of the QoS figure, although this will need to be confirmed through user trials.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros ≤ 300000

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 290000 } := by
  unfold Spec; decide
