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

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { messages := x.messages ++ [x.newMessage], newMessage := x.newMessage }
