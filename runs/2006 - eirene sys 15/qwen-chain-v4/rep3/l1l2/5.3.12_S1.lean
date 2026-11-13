import ContractForge
open ContractForge

-- 5.3.12/S1: The Cab radio shall be able to receive, display and store incoming short (SMS) text messages (see section 12).

-- L0 spec

structure Input where
  messages : List String
  newMessage : String
  deriving DecidableEq, Repr

structure Output where
  messages : List String
  newMessage : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.messages.length < 100
  post := fun i o =>
    o.newMessage ∈ i.messages ∧
    o.messages = i.messages ++ [o.newMessage]

example : Spec.pre { messages := ["msg1", "msg2"], newMessage := "msg2" } ∧
          Spec.post { messages := ["msg1", "msg2"], newMessage := "msg2" }
                    { messages := ["msg1", "msg2", "msg2"], newMessage := "msg2" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  newMessage : String
  messages   : List String
  deriving DecidableEq, Repr

def AddMessageContract : Contract Input Mid where
  pre  := fun i => i.messages.length < 100
  post := fun i m => m.newMessage ∈ i.messages ∧ m.messages = i.messages

def OutputMessagesContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.messages = m.messages ++ [m.newMessage] ∧
                     o.newMessage = m.newMessage

theorem po1 : Contract.Compatible AddMessageContract OutputMessagesContract := by
  discharge_po1 [AddMessageContract, OutputMessagesContract, Spec]

theorem po2 : Contract.Refines (AddMessageContract.seq OutputMessagesContract) Spec := by
  discharge_po2 [AddMessageContract, OutputMessagesContract, Spec]

-- L2 AddMessageContract (success=False)

def AddMessageContractImpl (x : Input) : Mid :=
  { newMessage := x.newMessage, messages := x.messages ++ [x.newMessage] }

-- L2 OutputMessagesContract (success=True)

def OutputMessagesContractImpl (x : Mid) : Output :=
  { messages := x.messages ++ [x.newMessage], newMessage := x.newMessage }

theorem OutputMessagesContractImpl_ok : OutputMessagesContract.Satisfies OutputMessagesContractImpl := by
  discharge_po3 [OutputMessagesContract, OutputMessagesContractImpl]
