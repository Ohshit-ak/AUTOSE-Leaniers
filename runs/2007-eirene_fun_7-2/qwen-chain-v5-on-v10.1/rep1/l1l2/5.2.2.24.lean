import ContractForge
open ContractForge

-- 5.2.2.24: 5.2.2.24 Once the call is terminated, the continuous visual alarm indication in the cab shall cease. (M)

-- L0 spec

structure Input where
  cabAlarm : Bool
  callTerminated : Bool
  deriving DecidableEq, Repr

structure Output where
  cabAlarm : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callTerminated
  post := fun i o => o.cabAlarm ↔ i.cabAlarm ∧ i.callTerminated

example : Spec.pre { cabAlarm := true, callTerminated := true } ∧ Spec.post { cabAlarm := true, callTerminated := true } { cabAlarm := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { cabAlarm := decide (x.cabAlarm ∧ x.callTerminated) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
