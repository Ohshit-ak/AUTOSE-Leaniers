import ContractForge
open ContractForge

-- 5.7.14/S1: An emergency power supply should be provided for Cab radios which will enable the driver's radio to continue to operate for a period of 6 hours in the event of failure of the train's main power supply, based on the following cycle (see section 4.5.21): (O)
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros ≤ 21600000000 ∧ o.elapsedMicros ≥ 21599999999

example : Spec.pre { } ∧ Spec.post { } { elapsedMicros := 21599999999 } := by
  unfold Spec; decide

example : Spec.pre { } ∧ Spec.post { } { elapsedMicros := 21600000000 } := by
  unfold Spec; decide
