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

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { processedMessage := x.c4iMessage, preparedMessage := x.c4iMessage }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
