import ContractForge
open ContractForge

-- 2.13.2/S3: In the case of IOC failure, no transfer of control to another IOC will be possible, due to the local connections and interfaces to the control electronics.

-- L0 spec

structure Input where
  iocFailed : Bool
  deriving DecidableEq, Repr

structure Output where
  controlPossible : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.iocFailed
  post := fun i o => o.controlPossible = false

example : Spec.pre { iocFailed := true } ∧
          Spec.post { iocFailed := true } { controlPossible := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { controlPossible := false }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
