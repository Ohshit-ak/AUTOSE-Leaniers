import ContractForge
open ContractForge

-- 3.1.5.1.1/S2: The THEMAS system shall limit the number of heating or cooling units t hat may be running simultaneously.

-- L0 spec

structure Input where
  runningUnits : Nat
  maxUnits     : Nat
  deriving DecidableEq, Repr

structure Output where
  runningUnits : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.runningUnits ≤ i.maxUnits
  post := fun i o => o.runningUnits = i.runningUnits

example : Spec.pre { runningUnits := 5, maxUnits := 10 } ∧
          Spec.post { runningUnits := 5, maxUnits := 10 } { runningUnits := 5 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { runningUnits := x.runningUnits }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
