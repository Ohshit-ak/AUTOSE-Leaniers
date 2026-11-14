import ContractForge
open ContractForge

-- 5.3.5: 5.3.5 Cab radios should be able to continue to operate for a period of at least 1 hour in the event of failure of the trains power supply, based on the following cycle: (O) point-to-point calls 20%; group calls 5%; standby 75%. Electromagnetic Compatibility

-- L0 spec

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros ≥ 3600000000

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 3600000000 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { elapsedMicros := 3600000000 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
