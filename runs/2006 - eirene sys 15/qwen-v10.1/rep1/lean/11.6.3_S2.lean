import ContractForge
open ContractForge

-- 11.6.3/S2: The signalling system suite shall include the Mobile Application Part (MAP).
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  includesMAP : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.includesMAP = true

example : Spec.pre {} ∧ Spec.post {} { includesMAP := true } := by
  unfold Spec; decide
