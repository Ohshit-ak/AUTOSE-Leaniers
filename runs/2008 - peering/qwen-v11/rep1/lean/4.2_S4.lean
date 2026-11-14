import ContractForge
open ContractForge

-- 4.2/S4: Messages can then be sent bi-directionally between the server and network elements.
-- compiles: True · rejects_bad_example: True · checked: True

structure Message where
  content : String
  deriving DecidableEq, Repr

structure Input where
  serverMessage : Message
  networkElementMessage : Message
  deriving DecidableEq, Repr

structure Output where
  serverMessage : Message
  networkElementMessage : Message
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.serverMessage.content = i.serverMessage.content ∧
                     o.networkElementMessage.content = i.networkElementMessage.content ∧
                     (o.serverMessage.content ≠ i.serverMessage.content ↔
                      o.networkElementMessage.content ≠ i.networkElementMessage.content)

example : Spec.pre { serverMessage := { content := "Hello" },
                     networkElementMessage := { content := "World" } } ∧
          Spec.post { serverMessage := { content := "Hello" },
                      networkElementMessage := { content := "World" } }
                    { serverMessage := { content := "Hello" },
                      networkElementMessage := { content := "World" } } := by
  unfold Spec; decide
