import ContractForge
open ContractForge

-- 3.2.5.2/S1: The TCS will have the functionality to process received C4I messages and to prepare C4I messages for transmission.

-- L0 spec

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

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { processedMessages := x.c4iMessages,
    preparedMessages := x.c4iMessages }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
