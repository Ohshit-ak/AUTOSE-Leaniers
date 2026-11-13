import ContractForge
open ContractForge

-- 2.9.3/I2: In addition, there is the need for transmission of images matching the original resolution. This high-quality transmission must require less than 20 sec, and can only be assisted with loss-less compression.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros < 20000000

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 19000000 } := by
  unfold Spec; decide
