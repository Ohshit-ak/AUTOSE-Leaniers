import ContractForge
open ContractForge

-- 4/ease-of-use/R2: The System must employ a single set of user interface rules, or a small number of sets to provide a familiar and common look and feel for the application.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ _ => True

example : Spec.pre { } ∧ Spec.post { } { } := by
  unfold Spec; decide
