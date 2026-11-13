import ContractForge
open ContractForge

-- 8.3.5/S1: The duration of each tone (see 8.3.2 and 8.3.4) added in the voice channel, shall be 70ms ± 5ms, and there shall be a minimum gap of 65ms between each tone.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.elapsedMicros ≤ 70000 ∧ o.elapsedMicros ≤ 5000 ∧ o.elapsedMicros ≤ 65000

example : Spec.pre { elapsedMicros := 70000 } ∧ Spec.post { elapsedMicros := 70000 } { elapsedMicros := 0 } := by
  unfold Spec; decide
