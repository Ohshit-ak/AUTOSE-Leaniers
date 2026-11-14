import ContractForge
open ContractForge

-- 3.4.2/S7: In any case, remote operation must include remote monitoring from the Gemini 8m Telescopes base facilities, together with access tools for diagnostic and test use.

-- L0 spec

structure Input where
  remoteMonitoring : Bool
  accessTools      : Bool
  deriving DecidableEq, Repr

structure Output where
  remoteMonitoring : Bool
  accessTools      : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.remoteMonitoring = true ∧ i.accessTools = true
  post := fun i o => o.remoteMonitoring = i.remoteMonitoring ∧
                     o.accessTools = i.accessTools

example : Spec.pre { remoteMonitoring := true, accessTools := true } ∧
          Spec.post { remoteMonitoring := true, accessTools := true }
                    { remoteMonitoring := true, accessTools := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { remoteMonitoring := x.remoteMonitoring,
    accessTools := x.accessTools }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
