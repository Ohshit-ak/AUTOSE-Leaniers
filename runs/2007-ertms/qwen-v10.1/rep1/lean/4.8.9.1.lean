import ContractForge
open ContractForge

-- 4.8.9.1: It shall be possible to send fixed text messages from track to train
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  message : String
  deriving DecidableEq, Repr

structure Output where
  sent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.message ≠ ""
  post := fun i o => o.sent = true

example : Spec.pre { message := "Fixed message" } ∧
          Spec.post { message := "Fixed message" } { sent := true } := by
  unfold Spec; decide
