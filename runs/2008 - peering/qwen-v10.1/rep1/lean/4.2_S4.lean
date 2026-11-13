import ContractForge
open ContractForge

-- 4.2/S4: Messages can then be sent bi-directionally between the server and network elements.
-- compiles: True · rejects_bad_example: None · checked: True

structure Message where
  content : String
  deriving DecidableEq, Repr

structure Input where
  serverMessages : List Message
  networkElementMessages : List Message
  deriving DecidableEq, Repr

structure Output where
  serverMessages : List Message
  networkElementMessages : List Message
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.serverMessages.Nodup ∧ i.networkElementMessages.Nodup
  post := fun i o => o.serverMessages = i.serverMessages ∧
                     o.networkElementMessages = i.networkElementMessages

example : Spec.pre { serverMessages := [{ content := "hello" }],
                     networkElementMessages := [{ content := "world" }] } ∧
          Spec.post { serverMessages := [{ content := "hello" }],
                      networkElementMessages := [{ content := "world" }] }
                    { serverMessages := [{ content := "hello" }],
                      networkElementMessages := [{ content := "world" }] } := by
  unfold Spec; decide
