import ContractForge
open ContractForge

-- 4.2/S4: Messages can then be sent bi-directionally between the server and network elements.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { serverMessages := x.serverMessages, networkElementMessages := x.networkElementMessages }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
