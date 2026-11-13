import ContractForge
open ContractForge

-- 4.9.5.1: The ETCS on-board shall be capable of sending to the trackside train integrity information detected by a system outside ETCS

-- L0 spec

structure Input where
  integrityInfo : String
  deriving DecidableEq, Repr

structure Output where
  sentToTrackside : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.integrityInfo ≠ ""
  post := fun i o => o.sentToTrackside = true

example : Spec.pre { integrityInfo := "Integrity OK" } ∧
          Spec.post { integrityInfo := "Integrity OK" }
                    { sentToTrackside := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { sentToTrackside := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
