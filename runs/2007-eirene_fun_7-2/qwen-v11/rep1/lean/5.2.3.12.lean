import ContractForge
open ContractForge

-- 5.2.3.12: 5.2.3.12 It shall be possible to present radio related prompts and information in a number of different languages. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  language : String
  deriving DecidableEq, Repr

structure Output where
  prompt   : String
  language : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.language ≠ ""
  post := fun i o => o.language = i.language ∧
                     (o.prompt = "Radio related prompt in " ++ i.language)

example : Spec.pre { language := "English" } ∧
          Spec.post { language := "English" }
                    { prompt := "Radio related prompt in English", language := "English" } := by
  unfold Spec; decide
