import ContractForge
open ContractForge

-- 3.2.5.2/S1: The TCS will have the functionality to process received C4I messages and to prepare C4I messages for transmission.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  c4iMessages : List String
  deriving DecidableEq, Repr

structure Output where
  processedMessages : List String
  preparedMessages  : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.c4iMessages.Nodup
  post := fun i o => o.processedMessages = i.c4iMessages ∧
                     o.preparedMessages.length = o.processedMessages.length

example : Spec.pre { c4iMessages := ["msg1", "msg2", "msg3"] } ∧
          Spec.post { c4iMessages := ["msg1", "msg2", "msg3"] }
                    { processedMessages := ["msg1", "msg2", "msg3"], preparedMessages := ["msg1", "msg2", "msg3"] } := by
  unfold Spec; decide
