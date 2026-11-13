import ContractForge
open ContractForge

-- 2.14.4/I3: .Gemini subsystem should be as self-contained and autonomous as possible, thereby decreasing the functional width of the interface to the rest of the Gemini system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  data : String
  deriving DecidableEq, Repr

structure Output where
  result : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.result = i.data

example : Spec.pre { data := "test" } ∧ Spec.post { data := "test" } { result := "test" } := by
  unfold Spec; decide
