import ContractForge
open ContractForge

-- 4.1.3.4b: Before authomatic transition to Shunting, ETCS shall request confirmation from the driver.

-- L0 spec

structure Input where
  driverConfirmed : Bool
  deriving DecidableEq, Repr

structure Output where
  transitionConfirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.driverConfirmed
  post := fun i o => o.transitionConfirmed = true

example : Spec.pre { driverConfirmed := true } ∧
          Spec.post { driverConfirmed := true } { transitionConfirmed := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { transitionConfirmed := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
