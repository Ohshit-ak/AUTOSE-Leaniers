import ContractForge
open ContractForge

-- 13.4.7: 13.4.7 The confirmation message shall be received at the central location with a 99% probability of success within 5 minutes of call termination. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  success       : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.success ↔ o.elapsedMicros ≤ 300000000

example : Spec.pre { elapsedMicros := 290000000 } ∧
          Spec.post { elapsedMicros := 290000000 } { success := true, elapsedMicros := 290000000 } := by
  unfold Spec; decide
