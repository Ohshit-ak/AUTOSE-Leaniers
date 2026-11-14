import ContractForge
open ContractForge

-- 13.4.7: 13.4.7 The confirmation message shall be received at the central location with a 99% probability of success within 5 minutes of call termination. (M)

-- L0 spec

structure Input where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  success       : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.success ↔ o.elapsedMicros ≤ 300000000

example : Spec.pre { elapsedMicros := 290000000 } ∧
          Spec.post { elapsedMicros := 290000000 } { success := true, elapsedMicros := 290000000 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { elapsedMicros := x.elapsedMicros, success := decide (x.elapsedMicros ≤ 300000000) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
