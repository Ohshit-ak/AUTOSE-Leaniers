import ContractForge
open ContractForge

-- 2.4/S1: The Get Real site runs as an extension of the OUS site e.g. ~getreal.ous.edu~ Being part of the OUS domain will maximize Google and other search engine hits.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o = {}

example : Spec.pre {} ∧ Spec.post {} {} := by
  unfold Spec; decide
