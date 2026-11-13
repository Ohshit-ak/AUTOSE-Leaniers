import ContractForge
open ContractForge

-- 4.3.6.6: The driver shall have the possibility to select the language, this does not concern non pre-defined texts sent from the trackside.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  language : String
  deriving DecidableEq, Repr

structure Output where
  language : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.language ≠ ""
  post := fun i o => o.language = i.language

example : Spec.pre { language := "en" } ∧
          Spec.post { language := "en" } { language := "en" } := by
  unfold Spec; decide
