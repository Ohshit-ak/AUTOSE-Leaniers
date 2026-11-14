import ContractForge
open ContractForge

-- 4.3.10.5: The retention period for the recorded data will be different and two levels are foreseen: Data to enable investigation of accidents need only be stored for at least 24 hours, and shall be very detailed. Operational data to enable assessment of driver performance shall be stored for at least one week.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros ≥ 86400000000

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 86400000000 } := by
  unfold Spec; decide
