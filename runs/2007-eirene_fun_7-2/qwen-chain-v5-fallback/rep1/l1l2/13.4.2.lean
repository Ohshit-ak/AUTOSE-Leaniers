import ContractForge
open ContractForge

-- 13.4.2: 13.4.2 The confirmation shall be generated automatically without input from the user. (M)

-- L0 spec

structure Input where
  emergencyCallId : Nat
  deriving DecidableEq, Repr

structure Output where
  confirmationGenerated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.confirmationGenerated = true

example : Spec.pre { emergencyCallId := 12345 } ∧ Spec.post { emergencyCallId := 12345 }
          { confirmationGenerated := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { confirmationGenerated := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
