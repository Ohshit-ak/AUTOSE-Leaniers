import ContractForge
open ContractForge

-- 5.1/R1: Upon the USB being plugged in the system shall be able to be deployed and operational in less than 1 minute.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.elapsedMicros < 60000000 ∧
                     (o.elapsedMicros = 0 → i.elapsedMicros = 0)

example : Spec.pre { elapsedMicros := 0 } ∧ Spec.post { elapsedMicros := 0 } { elapsedMicros := 0 } := by
  unfold Spec; decide
