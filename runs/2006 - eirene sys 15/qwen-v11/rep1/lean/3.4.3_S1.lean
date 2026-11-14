import ContractForge
open ContractForge

-- 3.4.3/S1: In order to achieve these times the passage of the call through any networks external to GSM (eg from the GSM MSC to a controller linked by an ISDN connection) must take less than 250ms.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros < 250000

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 245000 } := by
  unfold Spec; decide
