import ContractForge
open ContractForge

-- 12.3.1: 12.3.1 The maximum length of a message segment shall be 96 characters. A message can include several segments. (M)
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  message : String
  deriving DecidableEq, Repr

structure Output where
  segments : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.message.length ≤ 96
  post := fun i o => o.segments.length ≤ 1 ∧
                     o.segments.head?.getD "" = i.message ∧
                     o.segments.head?.length ≤ 96

example : Spec.pre { message := "a" } ∧
          Spec.post { message := "a" } { segments := ["a"], segments.head? = some "a" } := by
  unfold Spec; decide
