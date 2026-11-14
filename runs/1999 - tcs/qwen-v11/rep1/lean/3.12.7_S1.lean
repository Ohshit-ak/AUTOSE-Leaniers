import ContractForge
open ContractForge

-- 3.12.7/S1: The TCS shall be capable of operating continuously in functional Operation Mode for a minimum of 72 hours. [SSS442]
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros ≤ 259200000000 ∧ o.elapsedMicros ≥ 259199999999

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 259199999999 } := by
  unfold Spec; decide
