import ContractForge
open ContractForge

-- 4.8.8.5: The onboard equipment shall display plain text messages as received.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  message : String
  deriving DecidableEq, Repr

structure Output where
  displayed : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.displayed = i.message

example : Spec.pre { message := "Hello, world!" } ∧
          Spec.post { message := "Hello, world!" } { displayed := "Hello, world!" } := by
  unfold Spec; decide
