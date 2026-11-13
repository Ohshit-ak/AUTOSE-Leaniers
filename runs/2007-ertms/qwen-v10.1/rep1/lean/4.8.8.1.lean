import ContractForge
open ContractForge

-- 4.8.8.1: It shall be possible to send plain text messages from track to train.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  message : String
  deriving DecidableEq, Repr

structure Output where
  received : Bool
  message  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.message ≠ ""
  post := fun i o => o.received = true ∧ o.message = i.message

example : Spec.pre { message := "Hello, train!" } ∧
          Spec.post { message := "Hello, train!" }
                    { received := true, message := "Hello, train!" } := by
  unfold Spec; decide
