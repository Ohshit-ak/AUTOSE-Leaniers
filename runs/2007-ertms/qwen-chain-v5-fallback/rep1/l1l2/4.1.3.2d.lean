import ContractForge
open ContractForge

-- 4.1.3.2d: Permission received shall be indicated to the driver.

-- L0 spec

structure Input where
  permissionReceived : Bool
  deriving DecidableEq, Repr

structure Output where
  indicatedToDriver : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.permissionReceived
  post := fun i o => o.indicatedToDriver = i.permissionReceived

example : Spec.pre { permissionReceived := true } ∧
          Spec.post { permissionReceived := true }
                    { indicatedToDriver := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { indicatedToDriver := x.permissionReceived }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
