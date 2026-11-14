import ContractForge
open ContractForge

-- 3.2.5.2.1/S5: Review Incoming Annotated as well as Un-annotated Digital Imagery [SSS233] All digital messages received by the TCS shall be automatically checked for errors and corrected when possible. [SSS234] All erroneous messages that cannot be corrected by TCS shall be flagged to the operator. [SSS235] The TCS shall provide the capability to log all incoming and outgoing formatted tactical messages. [SSS236]

-- L0 spec

structure Input where
  messages : List String
  corrected : List String
  erroneous : List String
  logged    : List String
  deriving DecidableEq, Repr

structure Output where
  corrected : List String
  erroneous : List String
  logged    : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.messages.Nodup
  post := fun i o => 
    (∀ m ∈ i.messages, 
      (m ∈ o.corrected ∨ m ∈ o.erroneous) ∧
      (m ∈ o.logged ↔ m ∈ i.messages)) ∧
    o.corrected.length + o.erroneous.length = i.messages.length

example : Spec.pre { messages := ["msg1", "msg2", "msg3"],
                     corrected := ["msg1", "msg2", "msg3"],
                     erroneous := [],
                     logged := ["msg1", "msg2", "msg3"] } ∧
          Spec.post { messages := ["msg1", "msg2", "msg3"],
                      corrected := ["msg1", "msg2", "msg3"],
                      erroneous := [],
                      logged := ["msg1", "msg2", "msg3"] }
                    { corrected := ["msg1", "msg2", "msg3"], erroneous := [], logged := ["msg1", "msg2", "msg3"] } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  mapped : List String
  deriving DecidableEq, Repr

def MapMessagesContract : Contract Input Mid where
  pre  := fun i => i.messages.Nodup
  post := fun i m => ∀ m ∈ i.messages, (m ∈ m.mapped ∨ m ∉ m.mapped) ∧ (m ∈ m.mapped ↔ m ∈ i.messages)

def ProcessMessagesContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => 
    (∀ m ∈ m.mapped, 
      (m ∈ o.corrected ∨ m ∈ o.erroneous) ∧
      (m ∈ o.logged ↔ m ∈ m.mapped)) ∧
    o.corrected.length + o.erroneous.length = m.mapped.length
