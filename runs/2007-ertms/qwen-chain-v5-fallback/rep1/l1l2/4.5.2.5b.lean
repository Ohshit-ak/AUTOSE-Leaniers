import ContractForge
open ContractForge

-- 4.5.2.5b: The supervised speed shall not be shown on the DMI.

-- L0 spec

structure Input where
  speed : Nat
  deriving DecidableEq, Repr

structure Output where
  speedVisible : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.speed = 0
  post := fun i o => o.speedVisible = false

example : Spec.pre { speed := 0 } ∧ Spec.post { speed := 0 } { speedVisible := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { speedVisible := false }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
