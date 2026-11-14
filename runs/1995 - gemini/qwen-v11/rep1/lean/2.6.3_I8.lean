import ContractForge
open ContractForge

-- 2.6.3/I8: the Gemini standards will evolve over time as requirements and technology change
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ _ => True

example : Spec.pre {} ∧ Spec.post {} {} := by
  unfold Spec; decide
