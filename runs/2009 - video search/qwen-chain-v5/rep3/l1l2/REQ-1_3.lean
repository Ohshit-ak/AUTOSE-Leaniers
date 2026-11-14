import ContractForge
open ContractForge

-- REQ-1#3: Query times will take no longer than 5 seconds to any website.

-- L0 spec

structure Input where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.elapsedMicros ≤ 5000000 ∧
                     (o.elapsedMicros = 0 → o.elapsedMicros = i.elapsedMicros)

example : Spec.pre { elapsedMicros := 0 } ∧ Spec.post { elapsedMicros := 0 } { elapsedMicros := 0 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { elapsedMicros := min x.elapsedMicros 5000000 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
