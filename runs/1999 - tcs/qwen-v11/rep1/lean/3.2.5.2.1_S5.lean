import ContractForge
open ContractForge

-- 3.2.5.2.1/S5: Review Incoming Annotated as well as Un-annotated Digital Imagery [SSS233] All digital messages received by the TCS shall be automatically checked for errors and corrected when possible. [SSS234] All erroneous messages that cannot be corrected by TCS shall be flagged to the operator. [SSS235] The TCS shall provide the capability to log all incoming and outgoing formatted tactical messages. [SSS236]
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  messages : List String
  deriving DecidableEq, Repr

structure Output where
  corrected : List String
  flagged   : List String
  log       : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.messages.Nodup
  post := fun i o => 
    o.corrected.length + o.flagged.length = i.messages.length ∧
    (∀ m ∈ i.messages, m ∈ o.corrected ∨ m ∈ o.flagged) ∧
    (∀ m ∈ o.corrected, m = "corrected " ++ m) ∧
    (∀ m ∈ o.flagged, m = "flagged " ++ m) ∧
    o.log.length = i.messages.length ∧
    (∀ m ∈ i.messages, m ∈ o.log)

example : Spec.pre { messages := ["msg1", "msg2", "msg3"] } ∧
          Spec.post { messages := ["msg1", "msg2", "msg3"],
                      corrected := ["corrected msg1", "corrected msg2"],
                      flagged := ["flagged msg3"],
                      log := ["msg1", "msg2", "msg3"] } := by
  unfold Spec; decide
