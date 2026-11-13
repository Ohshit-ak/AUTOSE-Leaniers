import ContractForge
open ContractForge

-- 4.9.5.4: The driver shall be able to confirm the train integrity to the RBC manually. The confirmation requires the train to be stationary.

-- L0 spec

structure Input where
  isStationary : Bool
  deriving DecidableEq, Repr

structure Output where
  confirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.isStationary
  post := fun i o => o.confirmed = true

example : Spec.pre { isStationary := true } ∧ Spec.post { isStationary := true } { confirmed := true } := by
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
