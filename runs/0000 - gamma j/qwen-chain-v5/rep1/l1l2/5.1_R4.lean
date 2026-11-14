import ContractForge
open ContractForge

-- 5.1/R4: The system shall be able to add product to shopping cart in less than 2ms.

-- L0 spec

structure Input where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.elapsedMicros < 2000
  post := fun i o => o.elapsedMicros = i.elapsedMicros + 0 ∧
                     o.elapsedMicros < 2000

example : Spec.pre { elapsedMicros := 1999 } ∧ Spec.post { elapsedMicros := 1999 } { elapsedMicros := 1999 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { elapsedMicros := x.elapsedMicros + 0 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
