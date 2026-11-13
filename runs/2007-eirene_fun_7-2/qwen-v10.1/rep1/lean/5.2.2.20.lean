import ContractForge
open ContractForge

-- 5.2.2.20: 5.2.2.20 A continuous visual and short audible indication (from 0 to 20 seconds, for trials: 5 seconds) that the emergency function has been activated shall be provided in the cab. (Note that when the handset is off-hook, the audible indication shall be sounded from the loudspeaker at a low volume, but shall not be sounded from the handset.) (M)
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros ≤ 20000000

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 5000000 } := by
  unfold Spec; decide
