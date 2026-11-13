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

def ComputeNewMessageContract : Contract Input Mid where
  pre  := fun i => i.messages.length < 100
  post := fun i m => m.newMessage ∈ i.messages ∧ m.messages = i.messages

def AppendMessageContract : Contract Mid Output where
  pre  := fun m => m.newMessage ∈ m.messages
  post := fun m o => o.messages = m.messages ++ [m.newMessage] ∧ o.newMessage = m.newMessage

theorem po1 : Contract.Compatible ComputeNewMessageContract AppendMessageContract := by
  discharge_po1 [ComputeNewMessageContract, AppendMessageContract, Spec]

theorem po2 : Contract.Refines (ComputeNewMessageContract.seq AppendMessageContract) Spec := by
  discharge_po2 [ComputeNewMessageContract, AppendMessageContract, Spec]

-- L2 ComputeNewMessageContract (success=False)

def ComputeNewMessageContractImpl (x : Input) : Mid :=
  { newMessage := x.newMessage, messages := x.messages ++ [x.newMessage] }

-- L2 AppendMessageContract (success=True)

def AppendMessageContractImpl (x : Mid) : Output :=
  { messages := x.messages ++ [x.newMessage], newMessage := x.newMessage }

theorem AppendMessageContractImpl_ok : AppendMessageContract.Satisfies AppendMessageContractImpl := by
  discharge_po3 [AppendMessageContract, AppendMessageContractImpl]
