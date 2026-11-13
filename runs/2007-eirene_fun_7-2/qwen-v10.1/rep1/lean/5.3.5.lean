import ContractForge
open ContractForge

-- 5.3.5: 5.3.5 Cab radios should be able to continue to operate for a period of at least 1 hour in the event of failure of the trains power supply, based on the following cycle: (O) point-to-point calls 20%; group calls 5%; standby 75%. Electromagnetic Compatibility
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros ≥ 3600000000

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 3600000000 } := by
  unfold Spec; decide
