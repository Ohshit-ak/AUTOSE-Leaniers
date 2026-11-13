import ContractForge
open ContractForge

-- 13.5.5/S1: Railway Emergency call confirmation messages shall be of eMLPP priority 4 - "Railway information and all other calls" (see section 10.2).

-- L0 spec

structure Input where
  priority : Nat
  deriving DecidableEq, Repr

structure Output where
  confirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.priority = 4
  post := fun i o => o.confirmed = true

example : Spec.pre { priority := 4 } ∧ Spec.post { priority := 4 } { confirmed := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { confirmed := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
