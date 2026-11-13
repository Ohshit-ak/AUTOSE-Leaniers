import ContractForge
open ContractForge

-- 3.2.5.2/S1: The TCS will have the functionality to process received C4I messages and to prepare C4I messages for transmission.

-- L0 spec

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

-- L1 architecture (mode=chain, success=False)

structure Mid where
  processedMessage : String
  deriving DecidableEq, Repr

def ProcessMessageContract : Contract Input Mid where
  pre  := fun i => i.c4iMessage ≠ ""
  post := fun i m => m.processedMessage = i.c4iMessage

def PrepareMessageContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.processedMessage = m.processedMessage ∧
                     o.preparedMessage = m.processedMessage
