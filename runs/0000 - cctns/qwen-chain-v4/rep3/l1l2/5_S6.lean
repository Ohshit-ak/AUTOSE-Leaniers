import ContractForge
open ContractForge

-- 5/S6: The core services, support layer and security and access control components can be deployed as standard components with necessary configuration changes.

-- L0 spec

structure Input where
  coreServices   : List String
  supportLayer   : List String
  securityAccess : List String
  configChanges  : List String
  deriving DecidableEq, Repr

structure Output where
  deployedComponents : List String
  configChanges      : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.coreServices.Nodup ∧ i.supportLayer.Nodup ∧ i.securityAccess.Nodup ∧ i.configChanges.Nodup
  post := fun i o => o.deployedComponents = i.coreServices ++ i.supportLayer ++ i.securityAccess ∧
                      o.configChanges = i.configChanges

example : Spec.pre { coreServices := ["service1", "service2"], supportLayer := ["layer1", "layer2"], securityAccess := ["sec1", "sec2"], configChanges := ["change1", "change2"] } ∧
          Spec.post { coreServices := ["service1", "service2"], supportLayer := ["layer1", "layer2"], securityAccess := ["sec1", "sec2"], configChanges := ["change1", "change2"] }
                    { deployedComponents := ["service1", "service2", "layer1", "layer2", "sec1", "sec2"], configChanges := ["change1", "change2"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { deployedComponents := x.coreServices ++ x.supportLayer ++ x.securityAccess,
    configChanges := x.configChanges }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
