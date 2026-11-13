import ContractForge
open ContractForge

-- 4.4.2/S3: The VCD service provider for the piloting phase will be the Italian Business Registers System.
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
