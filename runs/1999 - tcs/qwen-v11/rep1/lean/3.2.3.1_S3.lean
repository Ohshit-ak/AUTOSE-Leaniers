import ContractForge
open ContractForge

-- 3.2.3.1/S3: The TCS shall be able to store up to 24 hours of payload data. [SSS184] External storage can be utilized for this purpose.
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros ≤ 86400000000

example : Spec.pre { } ∧ Spec.post { } { elapsedMicros := 86399999999 } := by
  unfold Spec; decide
