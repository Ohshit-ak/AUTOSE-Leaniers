import ContractForge
open ContractForge

-- 5.2.3.13: 5.2.3.13 By default, prompts and information shall be displayed in the language selected by the train owner (as stored within the system). (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  language : String
  deriving DecidableEq, Repr

structure Output where
  prompt  : String
  info    : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.language ≠ ""
  post := fun i o => o.prompt = i.language ∧ o.info = i.language

example : Spec.pre { language := "English" } ∧
          Spec.post { language := "English" }
                    { prompt := "English", info := "English" } := by
  unfold Spec; decide
