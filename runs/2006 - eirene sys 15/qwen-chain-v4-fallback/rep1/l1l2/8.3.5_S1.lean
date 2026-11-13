import ContractForge
open ContractForge

-- 8.3.5/S1: The duration of each tone (see 8.3.2 and 8.3.4) added in the voice channel, shall be 70ms ± 5ms, and there shall be a minimum gap of 65ms between each tone.

-- L0 spec

structure Input where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.elapsedMicros ≤ 70000 ∧ o.elapsedMicros ≤ 5000 ∧ o.elapsedMicros ≤ 65000

example : Spec.pre { elapsedMicros := 70000 } ∧ Spec.post { elapsedMicros := 70000 } { elapsedMicros := 0 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { elapsedMicros := min (min 70000 65000) 5000 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
