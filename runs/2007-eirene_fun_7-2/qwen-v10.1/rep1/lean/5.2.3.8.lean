import ContractForge
open ContractForge

-- 5.2.3.8: 5.2.3.8 The time should be able to be varied between 0 and 240 minutes, as a maintenance t function, allowing the radio to power up in a consistent state following minor operational procedures or power interruptions. (O)
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros ≤ 14400000000

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 14399999999 } := by
  unfold Spec; decide
