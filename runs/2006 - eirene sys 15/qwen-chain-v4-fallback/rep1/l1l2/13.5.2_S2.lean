import ContractForge
open ContractForge

-- 13.5.2/S2: The application must be able to deduce that a confirmation is necessary from the call priority, as all calls of 'Railway emergency' priority must be confirmed.

-- L0 spec

structure Input where
  priority : Nat
  deriving DecidableEq, Repr

structure Output where
  confirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.priority = 1 -- Assume 1 is the 'Railway emergency' priority
  post := fun i o => o.confirmed = true

example : Spec.pre { priority := 1 } ∧ Spec.post { priority := 1 } { confirmed := true } := by
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
