import ContractForge
open ContractForge

-- 3.2.5.2/S1: The TCS will have the functionality to process received C4I messages and to prepare C4I messages for transmission.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  c4iMessage : String
  deriving DecidableEq, Repr

structure Output where
  processedMessage : String
  preparedMessage  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.c4iMessage ≠ ""
  post := fun i o => o.processedMessage = i.c4iMessage ∧
                     o.preparedMessage = o.processedMessage

example : Spec.pre { c4iMessage := "C4I data" } ∧
          Spec.post { c4iMessage := "C4I data" }
                    { processedMessage := "C4I data", preparedMessage := "C4I data" } := by
  unfold Spec; decide
