import ContractForge
open ContractForge

-- 13.4.7: 13.4.7 The confirmation message shall be received at the central location with a 99% probability of success within 5 minutes of call termination. (M)
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  success       : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.success ↔ o.elapsedMicros ≤ 300000000

example : Spec.pre { } ∧ Spec.post { elapsedMicros := 299999999, success := true } := by
  unfold Spec; decide
