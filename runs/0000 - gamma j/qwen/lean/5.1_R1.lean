-- 5.1/R1: Upon the USB being plugged in the system shall be able to be deployed and operational in less than 1 minute.
-- checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros < 60000000

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 59999999 } := by
  unfold Spec; decide
